# Create resources to manage storage

resource "kubernetes_storage_class" "openwisp_storage_class" {
  metadata { name = "openwisp-storage-class" }
  storage_provisioner = "example.com/nfs"
  reclaim_policy      = var.persistent_data.reclaim_policy
  parameters = {
    type = var.persistent_data.persistent_disk_type
  }
}

resource "kubernetes_namespace" "nfs_server" {
  depends_on = [var.ow_cluster_ready]
  metadata { name = "nfs-server" }
}

resource "kubernetes_service" "nfs_server" {
  metadata {
    name      = "nfs-server"
    namespace = kubernetes_namespace.nfs_server.metadata[0].name
  }
  spec {
    selector = { role = "nfs-server" }

    # Open all the ports w/ protocol: TCP
    dynamic "port" {
      for_each = [for port in local.nfs_ports : {
        name = port.name
        port = port.port
      }]
      content {
        name     = "${port.value.name}tcp"
        protocol = "TCP"
        port     = port.value.port
      }
    }
    # Open all the ports w/ protocol: UDP
    dynamic "port" {
      for_each = [for port in local.nfs_ports : {
        name = port.name
        port = port.port
      }]
      content {
        name     = "${port.value.name}udp"
        protocol = "UDP"
        port     = port.value.port
      }
    }
    cluster_ip = var.persistent_data.nfs_server.internal_ip
  }
}

locals {
  nfs_ports = [
    { "name" : "nfs", "port" : 2049 },
    { "name" : "rpcbind", "port" : 111 },
    { "name" : "statdp", "port" : 32765 },
    { "name" : "statdo", "port" : 32766 },
    { "name" : "mountd", "port" : 32767 },
    { "name" : "nlockmgr", "port" : 32768 },
  ]
}

resource "kubernetes_deployment" "nfs_server" {
  metadata {
    name      = "nfs-server"
    namespace = kubernetes_namespace.nfs_server.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { role = "nfs-server" }
    }
    template {
      metadata {
        labels = { role = "nfs-server" }
      }
      spec {
        container {
          image             = "openwisp/openwisp-nfs:latest"
          name              = "nfs-server"
          image_pull_policy = var.openwisp_deployments.image_pull_policy
          security_context { privileged = true }
          env_from {
            config_map_ref { name = kubernetes_config_map.kubernetes_nfs_configmap.metadata.0.name }
          }
          resources {
            limits {
              cpu    = var.persistent_data.nfs_server.limit_cpu
              memory = var.persistent_data.nfs_server.limit_memory
            }
            requests {
              cpu    = var.persistent_data.nfs_server.requests_cpu
              memory = var.persistent_data.nfs_server.requests_memory
            }
          }
          # Open all the ports w/ protocol: TCP
          dynamic "port" {
            for_each = [for port in local.nfs_ports : {
              name = port.name
              port = port.port
            }]
            content {
              name           = "${port.value.name}tcp"
              protocol       = "TCP"
              container_port = port.value.port
            }
          }
          # Open all the ports w/ protocol: UDP
          dynamic "port" {
            for_each = [for port in local.nfs_ports : {
              name = port.name
              port = port.port
            }]
            content {
              name           = "${port.value.name}udp"
              protocol       = "UDP"
              container_port = port.value.port
            }
          }
          volume_mount {
            mount_path = "/exports"
            name       = "persistent-disk"
          }
        }
        volume {
          name = "persistent-disk"
          gce_persistent_disk {
            pd_name = var.persistent_data.persistent_disk_name
            fs_type = "ext4"
          }
        }
      }
    }
  }
}

locals {
  openwisp_volumes = var.openwisp_services.setup_database ? {
    0 = { "name" : "certs", "claim" : "certs-pv-claim", "storage" : var.persistent_data.sslcert_storage_size }
    1 = { "name" : "media", "claim" : "media-pv-claim", "storage" : var.persistent_data.media_storage_size }
    2 = { "name" : "static", "claim" : "static-pv-claim", "storage" : var.persistent_data.static_storage_size }
    3 = { "name" : "html", "claim" : "html-pv-claim", "storage" : var.persistent_data.html_storage_size }
    4 = { "name" : "postgres", "claim" : "postgres-pv-claim", "storage" : var.persistent_data.postgres_storage_size }
    } : {
    0 = { "name" : "certs", "claim" : "certs-pv-claim", "storage" : var.persistent_data.sslcert_storage_size }
    1 = { "name" : "media", "claim" : "media-pv-claim", "storage" : var.persistent_data.media_storage_size }
    2 = { "name" : "static", "claim" : "static-pv-claim", "storage" : var.persistent_data.static_storage_size }
    3 = { "name" : "html", "claim" : "html-pv-claim", "storage" : var.persistent_data.html_storage_size }
  }
}

resource "kubernetes_persistent_volume" "openwisp_persistent_volume" {
  depends_on = [kubernetes_storage_class.openwisp_storage_class]
  count      = length(local.openwisp_volumes)
  metadata {
    name = local.openwisp_volumes[count.index].name
    labels = {
      intended_claim = local.openwisp_volumes[count.index].claim
      nfs_version    = 3
    }
  }
  spec {
    storage_class_name = kubernetes_storage_class.openwisp_storage_class.metadata[0].name
    capacity = {
      storage = local.openwisp_volumes[count.index].storage
    }
    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = kubernetes_storage_class.openwisp_storage_class.reclaim_policy
    persistent_volume_source {
      nfs {
        path   = "/exports/${local.openwisp_volumes[count.index].name}"
        server = kubernetes_service.nfs_server.spec[0].cluster_ip
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "openwisp_persistent_volume_claim" {
  count = var.openwisp_services.setup_database ? 5 : 4
  metadata {
    name = kubernetes_persistent_volume.openwisp_persistent_volume[count.index].metadata[0].labels.intended_claim
    labels = {
      app = kubernetes_persistent_volume.openwisp_persistent_volume[count.index].metadata[0].name
    }
  }
  spec {
    storage_class_name = kubernetes_storage_class.openwisp_storage_class.metadata[0].name
    access_modes       = ["ReadWriteMany"]
    resources {
      requests = {
        storage = kubernetes_persistent_volume.openwisp_persistent_volume[count.index].spec[0].capacity.storage
      }
    }
    volume_name = kubernetes_persistent_volume.openwisp_persistent_volume[count.index].metadata[0].name
  }
}
