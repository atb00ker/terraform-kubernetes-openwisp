# All kubernetes network services

resource "kubernetes_service" "openwisp_cluster_ip" {
  depends_on = [var.ow_cluster_ready]
  for_each = {
    0 : { "port" : 8000, "name" : "dashboard", "app" : "openwisp-dashboard" }
    1 : { "port" : 8001, "name" : "controller", "app" : "openwisp-controller" }
    2 : { "port" : 8002, "name" : "radius", "app" : "openwisp-radius" }
    3 : { "port" : 8003, "name" : "topology", "app" : "openwisp-topology" }
    4 : { "port" : 8004, "name" : "daphne", "app" : "openwisp-daphne" }
    5 : { "port" : 5432, "name" : "postgres", "app" : "openwisp-postgres" }
    6 : { "port" : 6379, "name" : "redis", "app" : "redis" }
    7 : { "port" : 25, "name" : "postfix", "app" : "openwisp-postfix" }
    8 : { "port" : 80, "name" : "dashboard-internal", "app" : "openwisp-nginx" }
    9 : { "port" : 80, "name" : "controller-internal", "app" : "openwisp-nginx" }
  }
  metadata {
    name   = each.value.name
    labels = { app = each.value.app }
  }
  spec {
    type     = "ClusterIP"
    selector = { app = each.value.app }
    port { port = each.value.port }
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
    "app" : "openwisp-openvpn", "load_balancer_ip" : var.infrastructure_provider.openvpn_loadbalancer_address,
    "ports" : [
      { "name" : "vpn", "protocol" : "UDP", "port" : 1194 }
  ] }] : []
  _use_freeradius = var.openwisp_services.use_freeradius ? [{
    "name" : "freeradius", "hostname" : "freeradius.openwisp.org",
    "app" : "openwisp-freeradius", "load_balancer_ip" : var.infrastructure_provider.freeradius_loadbalancer_address,
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
    annotations = { "kubernetes.io/ingress.global-static-ip-name" = var.infrastructure_provider.http_loadbalancer_name }
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
