module "infrastructure" {
  source  = "atb00ker/openwisp/gcp"
  version = "0.1.0-alpha.4"
  google_services = {
    service_account             = file("account.json")
    project_id                  = "sample"
    region                      = "asia-south1"
    zone                        = "asia-south1-a"
    configure_gloud             = true
    common_resource_description = "This resource is created by terraform for OpenWISP deployment."
    use_cloud_sql               = false
    use_cloud_dns               = true
    disable_apis_on_destroy     = false
  }

  openwisp_services = {
    use_openvpn    = true
    use_freeradius = true
    setup_database = true
  }

  gke_node_groups = [
    {
      pool_name           = "primary-instance-pool"
      enable_autoscaling  = true
      initial_node_count  = 2
      min_node_count      = 2
      max_node_count      = 5
      auto_repair         = true
      auto_upgrade        = false
      is_preemptible      = false
      disk_size_gb        = 10
      disk_type           = "pd-standard"
      instance_image_type = "COS"
      machine_type        = "n1-standard-1"
      }, {
      pool_name           = "preemptible-instance-pool"
      enable_autoscaling  = false
      initial_node_count  = 1
      min_node_count      = 1
      max_node_count      = 10
      auto_repair         = true
      auto_upgrade        = false
      is_preemptible      = true
      disk_size_gb        = 10
      disk_type           = "pd-standard"
      instance_image_type = "COS"
      machine_type        = "n1-standard-1"
    }
  ]

  gce_persistent_disk = {
    # Persistent disk in which all the openwisp
    # Data is stored, this includes postfix storage, site
    # static content & user uploaded media (like floor plans)
    name = "openwisp-disk"
    type = "pd-standard"
    size = 10
  }

  gke_cluster = {
    # Configurations for your kubernetes cluster
    cluster_name             = "openwisp-cluster"
    kubernetes_version       = "1.14.9-gke.23"
    regional                 = false
    logging_service          = "logging.googleapis.com/kubernetes"
    monitoring_service       = "monitoring.googleapis.com/kubernetes"
    master_ipv4_cidr_block   = "172.16.0.48/28"
    enable_private_nodes     = true
    enable_private_endpoint  = false
    daily_maintenance_window = "05:00"
    authorized_networks = [
      {
        display_name = "office-static-address"
        cidr_block   = "192.0.2.10/32"
      },
      {
        display_name = "developers-address-range"
        cidr_block   = "192.0.2.0/24"
      },
    ]
  }

  network_config = {
    # OpenWISP deployment network options
    vpc_name                  = "openwisp-network"
    subnet_name               = "openwisp-cluster-subnet"
    subnet_cidr               = "10.130.0.0/20"
    services_cidr_range       = "10.0.0.0/14"
    pods_cidr_range           = "10.100.0.0/14"
    http_loadbalancer_ip_name = "openwisp-http-loadbalancer-ip"
    openvpn_ip_name           = "openwisp-openvpn-ip"
    freeradius_ip_name        = "openwisp-freeradius-ip"
    openwisp_dns_name         = "atb00ker.tk"
    openwisp_dns_zone_name    = "openwisp-dns"
    openwisp_dns_records_ttl  = 300
    subnet_flowlogs = {
      enable   = true
      interval = "INTERVAL_10_MIN"
      sampling = 0.5
      metadata = "INCLUDE_ALL_METADATA"
    }
  }
}

module "kubernetes" {
  source                  = "atb00ker/openwisp/kubernetes"
  version                 = "0.1.0-alpha.2"
  ow_cluster_ready        = module.infrastructure.ow_cluster_ready
  infrastructure_provider = module.infrastructure.infrastructure_provider
  openwisp_services       = module.infrastructure.openwisp_services

  kubernetes_services = {
    use_cert_manger   = true
    cert_manager_link = "https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml"
  }

  persistent_data = {
    nfs_server = {
      replicas        = 1
      internal_ip     = "10.0.10.240"
      limit_cpu       = 12
      requests_cpu    = 0.01
      limit_memory    = "100Gi"
      requests_memory = "100Mi"
    }
    persistent_disk_name         = module.infrastructure.ow_persistent_disk.name
    persistent_disk_type         = module.infrastructure.ow_persistent_disk.type
    persistent_disk_size         = module.infrastructure.ow_persistent_disk.size
    reclaim_policy               = "Retain"
    postfix_sslcert_storage_size = "50Mi"
    media_storage_size           = "5Gi"
    static_storage_size          = "50Mi"
    html_storage_size            = "100Mi"
    postgres_storage_size        = "3Gi"
  }

  kubernetes_configmap = {
    # The configurations for pods, these configurations are
    # shared between all pods except the postgres pod which
    # has seperate config variable. Read about the options
    # in the documentation. (docs/ENV.md)
    common_configmap_name             = "common-config"
    postgres_configmap_name           = "postgres-config"
    nfs_configmap_name                = "nfs-config"
    DASHBOARD_DOMAIN                  = "dashboard.example.com"
    CONTROLLER_DOMAIN                 = "controller.example.com"
    RADIUS_DOMAIN                     = "radius.example.com"
    TOPOLOGY_DOMAIN                   = "topology.example.com"
    EMAIL_DJANGO_DEFAULT              = "example@example.com"
    DJANGO_SECRET_KEY                 = "default_secret_key"
    DJANGO_ALLOWED_HOSTS              = ".example.com"
    TZ                                = "UTC"
    CERT_ADMIN_EMAIL                  = "example@example.com"
    SSL_CERT_MODE                     = false
    SET_RADIUS_TASKS                  = true
    SET_TOPOLOGY_TASKS                = true
    DB_NAME                           = "openwisp_db"
    DB_ENGINE                         = "django.contrib.gis.db.backends.postgis"
    DB_USER                           = "admin"
    DB_PASS                           = "admin"
    DB_PORT                           = 5432
    DB_OPTIONS                        = "{}"
    DJANGO_X509_DEFAULT_CERT_VALIDITY = 1825
    DJANGO_X509_DEFAULT_CA_VALIDITY   = 3650
    DJANGO_CORS_ORIGIN_ALLOW_ALL      = true
    DJANGO_LANGUAGE_CODE              = "en-gb"
    DJANGO_SENTRY_DSN                 = null
    DJANGO_LEAFET_CENTER_X_AXIS       = 0
    DJANGO_LEAFET_CENTER_Y_AXIS       = 0
    DJANGO_LEAFET_ZOOM                = 1
    EMAIL_BACKEND                     = "django.core.mail.backends.smtp.EmailBackend"
    EMAIL_HOST_PORT                   = 25
    EMAIL_HOST_USER                   = null
    EMAIL_HOST_PASSWORD               = null
    EMAIL_HOST_TLS                    = false
    POSTFIX_ALLOWED_SENDER_DOMAINS    = "example.org"
    POSTFIX_MYHOSTNAME                = "example.org"
    POSTFIX_DESTINATION               = "$myhostname"
    POSTFIX_MESSAGE_SIZE_LIMIT        = 0
    POSTFIX_MYNETWORKS                = "10.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
    POSTFIX_RELAYHOST_TLS_LEVEL       = "may"
    POSTFIX_RELAYHOST                 = "null"
    POSTFIX_RELAYHOST_USERNAME        = "null"
    POSTFIX_RELAYHOST_PASSWORD        = "null"
    FREERADIUS_ORGANIZATION           = "default"
    FREERADIUS_KEY                    = "testing123"
    FREERADIUS_CLIENTS                = "0.0.0.0/0"
    CRON_DELETE_OLD_RADACCT           = 365
    CRON_DELETE_OLD_POSTAUTH          = 365
    CRON_CLEANUP_STALE_RADACCT        = 365
    CRON_DELETE_OLD_USERS             = 12
    NGINX_HTTP2                       = "http2"
    NGINX_CLIENT_BODY_SIZE            = "5M"
    NGINX_IP6_STRING                  = null
    NGINX_IP6_80_STRING               = null
    NGINX_ADMIN_ALLOW_NETWORK         = "all"
    NGINX_SERVER_NAME_HASH_BUCKET     = 32
    NGINX_SSL_CONFIG                  = null
    NGINX_80_CONFIG                   = null
    NGINX_GZIP_SWITCH                 = "off"
    NGINX_GZIP_LEVEL                  = 6
    NGINX_GZIP_PROXIED                = "any"
    NGINX_GZIP_MIN_LENGTH             = 1000
    NGINX_GZIP_TYPES                  = "*"
    NGINX_HTTPS_ALLOWED_IPS           = "all"
    NGINX_HTTP_ALLOW                  = true
    NGINX_CUSTOM_FILE                 = false
    NINGX_REAL_REMOTE_ADDR            = "$remote_addr"
    VPN_ORG                           = "default"
    VPN_NAME                          = "default"
    VPN_CLIENT_NAME                   = "default"
    X509_NAME_CA                      = "default"
    X509_NAME_CERT                    = "default"
    X509_COUNTRY_CODE                 = "IN"
    X509_STATE                        = "Delhi"
    X509_CITY                         = "New Delhi"
    X509_ORGANIZATION_NAME            = "OpenWISP"
    X509_ORGANIZATION_UNIT_NAME       = "OpenWISP"
    X509_EMAIL                        = "certificate@example.com"
    X509_COMMON_NAME                  = "OpenWISP"
    DB_HOST                           = "postgres"
    EMAIL_HOST                        = "postfix"
    REDIS_HOST                        = "redis"
    DASHBOARD_APP_SERVICE             = "dashboard"
    CONTROLLER_APP_SERVICE            = "controller"
    RADIUS_APP_SERVICE                = "radius"
    TOPOLOGY_APP_SERVICE              = "topology"
    DEBUG_MODE                        = false
    DASHBOARD_APP_PORT                = 8000
    CONTROLLER_APP_PORT               = 8001
    RADIUS_APP_PORT                   = 8002
    TOPOLOGY_APP_PORT                 = 8003
    DASHBOARD_URI                     = "dashboard-internal"
    POSTFIX_DEBUG_MYNETWORKS          = "null"
    EXPORT_DIR                        = "/exports"
    EXPORT_OPTS                       = <<EOT
    ${module.infrastructure.infrastructure_provider.cluster.services_cidr_range}(rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync) ${module.infrastructure.infrastructure_provider.cluster.pods_cidr_range}(rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync) ${module.infrastructure.infrastructure_provider.cluster.nodes_cidr_range}(rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync)
    EOT
  }

  openwisp_deployments = {
    image_pull_policy = "IfNotPresent"
    restart_policy    = "Always"
    dashboard = {
      replicas       = 1
      image          = "openwisp/openwisp-dashboard:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    controller = {
      replicas       = 1
      image          = "openwisp/openwisp-controller:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    radius = {
      replicas       = 1
      image          = "openwisp/openwisp-radius:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    topology = {
      replicas       = 1
      image          = "openwisp/openwisp-topology:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    nginx = {
      replicas       = 1
      image          = "openwisp/openwisp-nginx:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    postgres = {
      replicas       = 1
      image          = "mdillon/postgis:10-alpine"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    postfix = {
      replicas       = 1
      image          = "openwisp/openwisp-postfix:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    freeradius = {
      replicas       = 1
      image          = "openwisp/openwisp-freeradius:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    openvpn = {
      replicas       = 1
      image          = "openwisp/openwisp-openvpn:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    celery = {
      replicas       = 1
      image          = "openwisp/openwisp-dashboard:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    celerybeat = {
      replicas       = 1
      image          = "openwisp/openwisp-dashboard:latest"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    redis = {
      replicas       = 1
      image          = "redis:alpine"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
  }
}
