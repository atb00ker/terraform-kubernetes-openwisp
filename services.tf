# All kubernetes network services


locals {
  _postgres_cluster_service = var.openwisp_services.setup_database ? [{
    "port" : 5432, "name" : "postgres", "app" : "openwisp-postgres"
  }] : []

  _cluster_services = [
    { "port" : 8000, "name" : "dashboard", "app" : "openwisp-dashboard" },
    { "port" : 8001, "name" : "controller", "app" : "openwisp-controller" },
    { "port" : 8002, "name" : "radius", "app" : "openwisp-radius" },
    { "port" : 8003, "name" : "topology", "app" : "openwisp-topology" },
    { "port" : 8004, "name" : "websocket", "app" : "openwisp-websocket" },
    { "port" : 6379, "name" : "redis", "app" : "redis" },
    { "port" : 25, "name" : "postfix", "app" : "openwisp-postfix" },
    { "port" : 80, "name" : "dashboard-internal", "app" : "openwisp-nginx" },
    { "port" : 80, "name" : "controller-internal", "app" : "openwisp-nginx" },
    { "port" : 80, "name" : "radius-internal", "app" : "openwisp-nginx" },
    { "port" : 80, "name" : "topology-internal", "app" : "openwisp-nginx" }
  ]
  cluster_services = concat(local._cluster_services, local._postgres_cluster_service)
}

resource "kubernetes_service" "openwisp_cluster_ip" {
  depends_on = [var.ow_cluster_ready]
  count      = length(local.cluster_services)
  metadata {
    name   = local.cluster_services[count.index].name
    labels = { app = local.cluster_services[count.index].app }
  }
  spec {
    type     = "ClusterIP"
    selector = { app = local.cluster_services[count.index].app }
    port { port = local.cluster_services[count.index].port }
  }
}

resource "kubernetes_service" "openwisp_nodeport" {
  depends_on = [var.ow_cluster_ready]
  metadata {
    name   = "openwisp-nginx"
    labels = { app = "openwisp-nginx" }
  }
  spec {
    type     = "NodePort"
    selector = { app = "openwisp-nginx" }
    port {
      name = "http"
      port = 80
    }
    port {
      name = "https"
      port = 443
    }
  }
}

locals {
  _use_openvpn = var.openwisp_services.use_openvpn ? [{
    "name" : "openvpn", "hostname" : "openvpn.openwisp.org",
    "app" : "openwisp-openvpn", "load_balancer_ip" : var.infrastructure.openvpn_loadbalancer_address,
    "ports" : [
      { "name" : "vpn", "protocol" : "UDP", "port" : 1194 }
  ] }] : []
  _use_freeradius = var.openwisp_services.use_freeradius ? [{
    "name" : "freeradius", "hostname" : "freeradius.openwisp.org",
    "app" : "openwisp-freeradius", "load_balancer_ip" : var.infrastructure.freeradius_loadbalancer_address,
    "ports" : [
      { "name" : "auth", "protocol" : "UDP", "port" : 1812 },
      { "name" : "acct", "protocol" : "UDP", "port" : 1813 }
  ] }] : []
  loadbalancers = concat(local._use_freeradius, local._use_openvpn)
}

resource "kubernetes_service" "openwisp_loadbalancers" {
  depends_on = [var.ow_cluster_ready]
  count      = length(local.loadbalancers)
  metadata {
    name        = local.loadbalancers[count.index].name
    annotations = { "external-dns.alpha.kubernetes.io/hostname" = local.loadbalancers[count.index].hostname }
  }
  spec {
    type     = "LoadBalancer"
    selector = { app = local.loadbalancers[count.index].app }
    dynamic "port" {
      for_each = [for port in local.loadbalancers[count.index].ports : {
        name     = port.name
        protocol = port.protocol
        port     = port.port
      }]
      content {
        name     = port.value.name
        protocol = port.value.protocol
        port     = port.value.port
      }
    }
    load_balancer_ip = local.loadbalancers[count.index].load_balancer_ip
  }
}

resource "kubernetes_ingress" "http_ingress" {
  depends_on = [var.ow_cluster_ready, kubernetes_deployment.openwisp_deployments]

  metadata {
    name        = "openwisp-http-ingress"
    annotations = { "kubernetes.io/ingress.global-static-ip-name" = var.infrastructure.http_loadbalancer_name }
    labels      = { "app" = "openwisp-nginx" }
  }
  spec {
    rule {
      http {
        path {
          backend {
            service_name = "openwisp-nginx"
            service_port = 80
          }
        }
      }
    }
  }
}
