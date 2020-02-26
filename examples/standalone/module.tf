module "kubernetes" {
  source  = "atb00ker/openwisp/kubernetes"
  version = "0.1.0-alpha.3"

  ow_cluster_ready = true
  infrastructure = {
    name                            = "google"
    http_loadbalancer_name          = "openwisp-http-loadbalancer-ip"
    openvpn_loadbalancer_address    = "192.168.2.10"
    freeradius_loadbalancer_address = "192.168.2.20"
    cluster = {
      name                = "openwisp-cluster"
      endpoint            = "192.168.2.80"
      ca_certificate      = "LS0--long--ca-certificate--value--"
      access_token        = "ya29.c.--long--access-token--value--"
      nodes_cidr_range    = "192.168.2.81"
      pods_cidr_range     = "192.168.2.82"
      services_cidr_range = "192.168.2.83"
    }
    database = {
      enabled     = false
      sslmode     = "disabled"
      ca_cert     = "--server-certificate-file-content--"
      client_cert = "--client-certificate-file-content--"
      client_key  = "--private-file-file-content--"
      username    = "admin"
      password    = "admin"
      name        = "openwisp_db"
      host        = "192.168.2.54"
    }
  }

  openwisp_services = {
    use_openvpn    = false
    use_freeradius = true
    setup_database = true
    setup_fresh    = true
  }

  kubernetes_services = {
    use_cert_manger   = true
    cert_manager_link = "https://github.com/jetstack/cert-manager/releases/download/v0.13.0/cert-manager.yaml"
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
    persistent_disk_name  = "openwisp-disk"
    persistent_disk_type  = "pd-standard"
    persistent_disk_size  = 10
    reclaim_policy        = "Retain"
    sslcert_storage_size  = "50Mi"
    media_storage_size    = "5Gi"
    static_storage_size   = "50Mi"
    html_storage_size     = "100Mi"
    postgres_storage_size = "3Gi"
  }

  kubernetes_configmap = {
    # The configurations for pods, these configurations are
    # shared between all pods except the postgres pod which
    # has seperate config variable. Read about the options
    # in the documentation. (docs/ENV.md)
    DASHBOARD_DOMAIN                  = "dashboard.example.com"
    CONTROLLER_DOMAIN                 = "controller.example.com"
    RADIUS_DOMAIN                     = "radius.example.com"
    TOPOLOGY_DOMAIN                   = "topology.example.com"
    EMAIL_DJANGO_DEFAULT              = "example@example.com"
    DJANGO_SECRET_KEY                 = "default_secret_key"
    DJANGO_ALLOWED_HOSTS              = ".example.com"
    TZ                                = "UTC"
    CERT_ADMIN_EMAIL                  = "example@example.com"
    SSL_CERT_MODE                     = "External"
    SET_RADIUS_TASKS                  = true
    SET_TOPOLOGY_TASKS                = true
    DB_ENGINE                         = "django.contrib.gis.db.backends.postgis"
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
    DJANGO_LOG_LEVEL                  = "INFO"
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
    NGINX_HTTPS_ALLOWED_IPS           = "10.0.0.0/8"
    NGINX_HTTP_ALLOW                  = true
    NGINX_CUSTOM_FILE                 = false
    NINGX_REAL_REMOTE_ADDR            = "$real_ip"
    VPN_ORG                           = "default"
    VPN_NAME                          = "default"
    VPN_CLIENT_NAME                   = "default-vpn-client"
    X509_NAME_CA                      = "default"
    X509_NAME_CERT                    = "default"
    X509_COUNTRY_CODE                 = "IN"
    X509_STATE                        = "Delhi"
    X509_CITY                         = "New Delhi"
    X509_ORGANIZATION_NAME            = "OpenWISP"
    X509_ORGANIZATION_UNIT_NAME       = "OpenWISP"
    X509_EMAIL                        = "certificate@example.com"
    X509_COMMON_NAME                  = "OpenWISP"
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
    EXPORT_OPTS                       = "*(rw,fsid=0,insecure,no_root_squash,no_subtree_check,sync)"
  }

  openwisp_deployments = {
    image_pull_policy = "IfNotPresent"
    restart_policy    = "Always"
    dashboard = {
      replicas       = 1
      image          = "openwisp/openwisp-dashboard:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    controller = {
      replicas       = 1
      image          = "openwisp/openwisp-controller:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    radius = {
      replicas       = 1
      image          = "openwisp/openwisp-radius:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    topology = {
      replicas       = 1
      image          = "openwisp/openwisp-topology:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    nginx = {
      replicas       = 1
      image          = "openwisp/openwisp-nginx:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    postgres = {
      replicas       = 1
      image          = "mdillon/postgis:11-alpine"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    postfix = {
      replicas       = 1
      image          = "openwisp/openwisp-postfix:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    freeradius = {
      replicas       = 1
      image          = "openwisp/openwisp-freeradius:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    openvpn = {
      replicas       = 1
      image          = "openwisp/openwisp-openvpn:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    celery = {
      replicas       = 1
      image          = "openwisp/openwisp-dashboard:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    celerybeat = {
      replicas       = 1
      image          = "openwisp/openwisp-dashboard:alpha.1"
      limit_cpu      = 2
      request_cpu    = 0.001
      limit_memory   = "2Gi"
      request_memory = "50Mi"
    }
    websocket = {
      replicas       = 1
      image          = "openwisp/openwisp-websocket:alpha.1"
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
