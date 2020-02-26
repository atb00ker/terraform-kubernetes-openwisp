# All the deployments for OpenWISP services

# Init Job(s)
resource "kubernetes_job" "install_postgis_on_db" {
  count = var.infrastructure.database.enabled && var.openwisp_services.setup_fresh ? 1 : 0
  metadata { name = "setup-openwisp" }
  spec {
    template {
      metadata {}
      spec {
        container {
          name  = "install-postgis"
          image = "jbergknoff/postgresql-client"
          args  = ["--command", "CREATE EXTENSION postgis;"]
          env_from {
            config_map_ref { name = kubernetes_config_map.kubernetes_postgres_configmap.metadata.0.name }
          }
          volume_mount {
            name       = "postgresql-certificates"
            mount_path = "/var/lib/postgres/ssl/"
            read_only  = true
          }
        }
        volume {
          name = "postgresql-certificates"
          secret {
            secret_name  = "postgresql-certificates"
            default_mode = "0600"
          }
        }
        restart_policy = "Never"
      }
    }
  }
}

locals {
  # Volume Mounts
  _init_volume_mounts = {
    "postfix" : { claim = local.openwisp_volumes[0].claim, path = "/etc/ssl/mail", name = "openwisp-certs-data" },
    "media" : { claim = local.openwisp_volumes[1].claim, path = "/opt/openwisp/media", name = "user-media-data" },
    "static" : { claim = local.openwisp_volumes[2].claim, path = "/opt/openwisp/static", name = "static-files" },
    "html" : { claim = local.openwisp_volumes[3].claim, path = "/opt/openwisp/public_html", name = "openwisp-html-data" },
  }

  _postgres_volume_mount = var.openwisp_services.setup_database ? {
    "postgres" : { claim = local.openwisp_volumes[4].claim, path = "/var/lib/postgresql/data", name = "openwisp-postgres-data" }
  } : {}

  _volume_mounts = merge(local._init_volume_mounts, local._postgres_volume_mount)

  # Deployments
  _postgres_deployment = var.openwisp_services.setup_database ? [
    {
      "name" : "openwisp-postgres", "app" : "openwisp-postgres",
      "deployment_config" : var.openwisp_deployments.postgres,
      "configmap" : kubernetes_config_map.kubernetes_openwisp_postgres_configmap.metadata.0.name,
      "volume_mount" : [local._volume_mounts.postgres],
      "readiness_technique" : null, "liveness_technique" : null,
      "openports" : [], "capabilities" : [], "env" : [],
      "postgres_connection" : [],
    }
  ] : []

  _openwisp_deployments = [
    {
      "name" : "openwisp-dashboard", "app" : "openwisp-dashboard",
      "deployment_config" : var.openwisp_deployments.dashboard,
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name,
      "volume_mount" : [local._volume_mounts.static, local._volume_mounts.media],
      "readiness_technique" : "command", "readiness_command" : ["cat", "/opt/openwisp/uwsgi.pid"],
      "liveness_technique" : null, "openports" : [], "capabilities" : [], "env" : [],
      "postgres_connection" : [1],
    },
    {
      "name" : "openwisp-websocket", "app" : "openwisp-websocket",
      "deployment_config" : var.openwisp_deployments.websocket,
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name,
      "readiness_technique" : "command", "readiness_command" : ["cat", "/opt/openwisp/supervisord.pid"],
      "volume_mount" : [], "liveness_technique" : null, "openports" : [], "capabilities" : [], "env" : [],
      "postgres_connection" : [1],
    },
    {
      "name" : "openwisp-controller", "app" : "openwisp-controller",
      "deployment_config" : var.openwisp_deployments.controller, "env" : [],
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name,
      "readiness_technique" : "command", "readiness_command" : ["cat", "/opt/openwisp/uwsgi.pid"],
      "volume_mount" : [], "liveness_technique" : null, "openports" : [], "capabilities" : [],
      "postgres_connection" : [1],
    },
    {
      "name" : "openwisp-radius", "app" : "openwisp-radius",
      "deployment_config" : var.openwisp_deployments.radius, "env" : [],
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name,
      "readiness_technique" : "command", "readiness_command" : ["cat", "/opt/openwisp/uwsgi.pid"],
      "volume_mount" : [], "liveness_technique" : null, "openports" : [], "capabilities" : [],
      "postgres_connection" : [1],
    },
    {
      "name" : "openwisp-topology", "app" : "openwisp-topology",
      "deployment_config" : var.openwisp_deployments.topology
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name
      "volume_mount" : [local._volume_mounts.media],
      "readiness_technique" : "command", "readiness_command" : ["cat", "/opt/openwisp/uwsgi.pid"],
      "liveness_technique" : null, "openports" : [], "capabilities" : [], "env" : [],
      "postgres_connection" : [1],
    },
    {
      "name" : "openwisp-celery", "app" : "openwisp-celery",
      "deployment_config" : var.openwisp_deployments.celery
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name
      "volume_mount" : [], "readiness_technique" : null, "liveness_technique" : null,
      "openports" : [], "capabilities" : [],
      "postgres_connection" : [1],
      "env" : [
        { "name" : "MODULE_NAME", "value" : "celery" },
      ],
    },
    {
      "name" : "openwisp-celerybeat", "app" : "openwisp-celerybeat",
      "deployment_config" : var.openwisp_deployments.celerybeat
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name
      "volume_mount" : [], "readiness_technique" : null, "liveness_technique" : null,
      "openports" : [], "capabilities" : [],
      "postgres_connection" : [1],
      "env" : [
        { "name" : "MODULE_NAME", "value" : "celerybeat" },
      ],
    },
    {
      "name" : "openwisp-nginx", "app" : "openwisp-nginx",
      "deployment_config" : var.openwisp_deployments.nginx
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name
      "volume_mount" : [
        merge(local._volume_mounts.static, { read_only : "true" }),
        merge(local._volume_mounts.media, { read_only : "true" }),
        local._volume_mounts.html,
      ],
      "readiness_technique" : "httpget",
      "readiness_path" : "/status",
      "readiness_port" : "80",
      "liveness_technique" : "httpget",
      "liveness_path" : "/status",
      "liveness_port" : "80",
      "openports" : [443, 80], "capabilities" : [], "env" : [],
      "postgres_connection" : [],
    },
    {
      "name" : "openwisp-postfix", "app" : "openwisp-postfix",
      "deployment_config" : var.openwisp_deployments.postfix
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name
      "volume_mount" : [local._volume_mounts.postfix],
      "readiness_technique" : null, "liveness_technique" : null,
      "openports" : [], "capabilities" : [], "env" : [],
      "postgres_connection" : [],
    },
    {
      "name" : "redis", "app" : "redis",
      "deployment_config" : var.openwisp_deployments.redis
      "configmap" : kubernetes_config_map.kubernetes_common_configmap.metadata.0.name
      "volume_mount" : [], "readiness_technique" : null, "liveness_technique" : null,
      "openports" : [], "capabilities" : [], "env" : [],
      "postgres_connection" : [],
    },
  ]
  openwisp_deployments = concat(local._openwisp_deployments, local._postgres_deployment)
}

resource "kubernetes_deployment" "openwisp_deployments" {
  depends_on = [
    var.ow_cluster_ready,
    kubernetes_persistent_volume_claim.openwisp_persistent_volume_claim,
    kubernetes_deployment.nfs_server,
    kubernetes_job.install_postgis_on_db,
  ]
  count = length(local.openwisp_deployments)
  metadata { name = local.openwisp_deployments[count.index].name }

  spec {
    template {
      metadata { labels = { app = local.openwisp_deployments[count.index].app } }
      spec {
        container {
          image             = local.openwisp_deployments[count.index].deployment_config.image
          name              = local.openwisp_deployments[count.index].name
          image_pull_policy = var.openwisp_deployments.image_pull_policy
          env_from {
            config_map_ref { name = local.openwisp_deployments[count.index].configmap }
          }

          dynamic "volume_mount" {
            for_each = [for mount in local.openwisp_deployments[count.index].volume_mount : {
              name = mount.name
              path = mount.path
            }]
            content {
              name       = volume_mount.value.name
              mount_path = volume_mount.value.path
            }
          }

          dynamic "volume_mount" {
            for_each = local.openwisp_deployments[count.index].postgres_connection
            content {
              name       = "postgresql-certificates"
              mount_path = "/var/lib/postgres/ssl/"
              read_only  = true
            }
          }

          dynamic "port" {
            for_each = local.openwisp_deployments[count.index].openports
            content { container_port = port.value }
          }

          resources {
            limits {
              cpu    = local.openwisp_deployments[count.index].deployment_config.limit_cpu
              memory = local.openwisp_deployments[count.index].deployment_config.limit_memory
            }
            requests {
              cpu    = local.openwisp_deployments[count.index].deployment_config.request_cpu
              memory = local.openwisp_deployments[count.index].deployment_config.request_memory
            }
          }

          dynamic "liveness_probe" {
            # For loop hack to make autoscaling optional, there may be a
            # better way in the future terrform releases.
            for_each = local.openwisp_deployments[count.index].liveness_technique == "httpget" ? [1] : []
            content {
              http_get {
                path = local.openwisp_deployments[count.index].liveness_path
                port = local.openwisp_deployments[count.index].liveness_port
              }
              initial_delay_seconds = 15
              period_seconds        = 30
            }
          }

          dynamic "readiness_probe" {
            # For loop hack to make autoscaling optional, there may be a
            # better way in the future terrform releases.
            for_each = local.openwisp_deployments[count.index].readiness_technique == "command" ? [1] : []
            content {
              exec { command = local.openwisp_deployments[count.index].readiness_command }
              initial_delay_seconds = 90
              period_seconds        = 30
              failure_threshold     = 2
              success_threshold     = 2
            }
          }

          dynamic "readiness_probe" {
            # For loop hack to make autoscaling optional, there may be a
            # better way in the future terrform releases.
            for_each = local.openwisp_deployments[count.index].readiness_technique == "httpget" ? [1] : []
            content {
              http_get {
                path = local.openwisp_deployments[count.index].readiness_path
                port = local.openwisp_deployments[count.index].readiness_port
              }
              initial_delay_seconds = 15
              period_seconds        = 30
              failure_threshold     = 2
              success_threshold     = 2
            }
          }
        }

        dynamic "volume" {
          for_each = [for mount in local.openwisp_deployments[count.index].volume_mount : {
            name      = mount.name
            claim     = mount.claim
            read_only = lookup(mount, "read_only", false)
          }]
          content {
            name = volume.value.name
            persistent_volume_claim {
              claim_name = volume.value.claim
              read_only  = volume.value.read_only
            }
          }
        }

        dynamic "volume" {
          for_each = local.openwisp_deployments[count.index].postgres_connection
          content {
            name = "postgresql-certificates"
            secret {
              secret_name  = "postgresql-certificates"
              default_mode = "0600"
            }
          }
        }

        restart_policy = var.openwisp_deployments.restart_policy
      }
    }
    selector {
      match_labels = { app = local.openwisp_deployments[count.index].app }
    }
    replicas = local.openwisp_deployments[count.index].deployment_config.replicas
  }
}


resource "kubernetes_deployment" "freeradius_deployment" {
  count      = var.openwisp_services.use_freeradius ? 1 : 0
  depends_on = [kubernetes_persistent_volume_claim.openwisp_persistent_volume_claim]
  metadata { name = "openwisp-freeradius" }

  spec {
    template {
      metadata { labels = { app = "openwisp-freeradius" } }
      spec {
        container {
          image             = var.openwisp_deployments.freeradius.image
          name              = "openwisp-freeradius"
          image_pull_policy = var.openwisp_deployments.image_pull_policy
          env_from {
            config_map_ref { name = kubernetes_config_map.kubernetes_common_configmap.metadata.0.name }
          }

          resources {
            limits {
              cpu    = var.openwisp_deployments.freeradius.limit_cpu
              memory = var.openwisp_deployments.freeradius.limit_memory
            }
            requests {
              cpu    = var.openwisp_deployments.freeradius.request_cpu
              memory = var.openwisp_deployments.freeradius.request_memory
            }
          }
          volume_mount {
            name       = "postgresql-certificates"
            mount_path = "/var/lib/postgres/ssl/"
            read_only  = true
          }
        }

        volume {
          name = "postgresql-certificates"
          secret {
            secret_name  = "postgresql-certificates"
            default_mode = "0600"
          }
        }
        restart_policy = var.openwisp_deployments.restart_policy
      }
    }
    selector {
      match_labels = { app = "openwisp-freeradius" }
    }
    replicas = var.openwisp_deployments.freeradius.replicas
  }
}


resource "kubernetes_deployment" "openvpn_deployment" {
  count      = var.openwisp_services.use_openvpn ? 1 : 0
  depends_on = [kubernetes_persistent_volume_claim.openwisp_persistent_volume_claim]
  metadata { name = "openwisp-openvpn" }

  spec {
    template {
      metadata { labels = { app = "openwisp-openvpn" } }
      spec {
        container {
          image             = var.openwisp_deployments.openvpn.image
          name              = "openwisp-openvpn"
          image_pull_policy = var.openwisp_deployments.image_pull_policy
          env_from {
            config_map_ref { name = kubernetes_config_map.kubernetes_common_configmap.metadata.0.name }
          }

          security_context {
            allow_privilege_escalation = false
            capabilities {
              add = ["NET_ADMIN"]
            }
          }

          resources {
            limits {
              cpu    = var.openwisp_deployments.openvpn.limit_cpu
              memory = var.openwisp_deployments.openvpn.limit_memory
            }
            requests {
              cpu    = var.openwisp_deployments.openvpn.request_cpu
              memory = var.openwisp_deployments.openvpn.request_memory
            }
          }

          volume_mount {
            name       = "postgresql-certificates"
            mount_path = "/var/lib/postgres/ssl/"
            read_only  = true
          }
        }

        volume {
          name = "postgresql-certificates"
          secret {
            secret_name  = "postgresql-certificates"
            default_mode = "0600"
          }
        }
        restart_policy = var.openwisp_deployments.restart_policy
      }
    }
    selector {
      match_labels = { app = "openwisp-openvpn" }
    }
    replicas = var.openwisp_deployments.openvpn.replicas
  }
}
