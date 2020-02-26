# Contains all the variables used in this module.

variable "infrastructure" {
  type = object({
    name                            = string
    http_loadbalancer_name          = string
    openvpn_loadbalancer_address    = string
    freeradius_loadbalancer_address = string
    cluster = object({
      name                = string
      endpoint            = string
      access_token        = string
      ca_certificate      = string
      nodes_cidr_range    = string
      pods_cidr_range     = string
      services_cidr_range = string
    })
    database = object({
      enabled     = bool
      sslmode     = string
      ca_cert     = string
      client_cert = string
      client_key  = string
      username    = string
      password    = string
      name        = string
      host        = string
    })
  })
  description = "Find documentation here: https://github.com/atb00ker/terraform-kubernetes-openwisp/blob/master/docs/input.md."
}

variable "kubernetes_services" {
  type = object({
    use_cert_manger   = bool
    cert_manager_link = string
  })
  description = "Find documentation here: https://github.com/atb00ker/terraform-kubernetes-openwisp/blob/master/docs/input.md."
}

variable "ow_cluster_ready" {
  type        = bool
  description = "Find documentation here: https://github.com/atb00ker/terraform-kubernetes-openwisp/blob/master/docs/input.md."
}

variable "ow_kubectl_ready" {
  type        = bool
  default     = false
  description = "Find documentation here: https://github.com/atb00ker/terraform-kubernetes-openwisp/blob/master/docs/input.md."
}

variable "openwisp_services" {
  type = object({
    use_openvpn    = bool
    use_freeradius = bool
    setup_database = bool
    setup_fresh    = bool
  })
  description = "Find documentation here: https://github.com/atb00ker/terraform-kubernetes-openwisp/blob/master/docs/input.md."
}

variable "persistent_data" {
  type = object({
    nfs_server = object({
      internal_ip     = string
      limit_cpu       = number
      requests_cpu    = number
      limit_memory    = string
      requests_memory = string
    })
    persistent_disk_name  = string
    persistent_disk_type  = string
    persistent_disk_size  = number
    reclaim_policy        = string
    postgres_storage_size = string
    sslcert_storage_size  = string
    media_storage_size    = string
    static_storage_size   = string
    html_storage_size     = string
  })
  description = "Find documentation here: https://github.com/atb00ker/terraform-kubernetes-openwisp/blob/master/docs/input.md."
}

variable "kubernetes_configmap" {
  type = object({
    DASHBOARD_DOMAIN                  = string
    CONTROLLER_DOMAIN                 = string
    RADIUS_DOMAIN                     = string
    TOPOLOGY_DOMAIN                   = string
    EMAIL_DJANGO_DEFAULT              = string
    DJANGO_SECRET_KEY                 = string
    DJANGO_ALLOWED_HOSTS              = string
    TZ                                = string
    CERT_ADMIN_EMAIL                  = string
    SSL_CERT_MODE                     = string
    SET_RADIUS_TASKS                  = bool
    SET_TOPOLOGY_TASKS                = bool
    DB_ENGINE                         = string
    DB_PORT                           = number
    DB_OPTIONS                        = string
    DJANGO_X509_DEFAULT_CERT_VALIDITY = number
    DJANGO_X509_DEFAULT_CA_VALIDITY   = number
    DJANGO_CORS_ORIGIN_ALLOW_ALL      = bool
    DJANGO_LANGUAGE_CODE              = string
    DJANGO_SENTRY_DSN                 = string
    DJANGO_LEAFET_CENTER_X_AXIS       = number
    DJANGO_LEAFET_CENTER_Y_AXIS       = number
    DJANGO_LEAFET_ZOOM                = number
    DJANGO_LOG_LEVEL                  = string
    EMAIL_BACKEND                     = string
    EMAIL_HOST_PORT                   = number
    EMAIL_HOST_USER                   = string
    EMAIL_HOST_PASSWORD               = string
    EMAIL_HOST_TLS                    = bool
    POSTFIX_ALLOWED_SENDER_DOMAINS    = string
    POSTFIX_MYHOSTNAME                = string
    POSTFIX_DESTINATION               = string
    POSTFIX_MESSAGE_SIZE_LIMIT        = number
    POSTFIX_MYNETWORKS                = string
    POSTFIX_RELAYHOST_TLS_LEVEL       = string
    POSTFIX_RELAYHOST                 = string
    POSTFIX_RELAYHOST_USERNAME        = string
    POSTFIX_RELAYHOST_PASSWORD        = string
    FREERADIUS_ORGANIZATION           = string
    FREERADIUS_KEY                    = string
    FREERADIUS_CLIENTS                = string
    CRON_DELETE_OLD_RADACCT           = number
    CRON_DELETE_OLD_POSTAUTH          = number
    CRON_CLEANUP_STALE_RADACCT        = number
    CRON_DELETE_OLD_USERS             = number
    NGINX_HTTP2                       = string
    NGINX_CLIENT_BODY_SIZE            = string
    NGINX_IP6_STRING                  = string
    NGINX_IP6_80_STRING               = string
    NGINX_ADMIN_ALLOW_NETWORK         = string
    NGINX_SERVER_NAME_HASH_BUCKET     = number
    NGINX_SSL_CONFIG                  = string
    NGINX_80_CONFIG                   = string
    NGINX_GZIP_SWITCH                 = string
    NGINX_GZIP_LEVEL                  = number
    NGINX_GZIP_PROXIED                = string
    NGINX_GZIP_MIN_LENGTH             = number
    NGINX_GZIP_TYPES                  = string
    NGINX_HTTPS_ALLOWED_IPS           = string
    NGINX_HTTP_ALLOW                  = bool
    NGINX_CUSTOM_FILE                 = bool
    NINGX_REAL_REMOTE_ADDR            = string
    VPN_ORG                           = string
    VPN_NAME                          = string
    VPN_CLIENT_NAME                   = string
    X509_NAME_CA                      = string
    X509_NAME_CERT                    = string
    X509_COUNTRY_CODE                 = string
    X509_STATE                        = string
    X509_CITY                         = string
    X509_ORGANIZATION_NAME            = string
    X509_ORGANIZATION_UNIT_NAME       = string
    X509_EMAIL                        = string
    X509_COMMON_NAME                  = string
    EMAIL_HOST                        = string
    REDIS_HOST                        = string
    DASHBOARD_APP_SERVICE             = string
    CONTROLLER_APP_SERVICE            = string
    RADIUS_APP_SERVICE                = string
    TOPOLOGY_APP_SERVICE              = string
    DEBUG_MODE                        = bool
    DASHBOARD_APP_PORT                = number
    CONTROLLER_APP_PORT               = number
    RADIUS_APP_PORT                   = number
    TOPOLOGY_APP_PORT                 = number
    DASHBOARD_URI                     = string
    POSTFIX_DEBUG_MYNETWORKS          = string
    EXPORT_DIR                        = string
    EXPORT_OPTS                       = string
  })
  description = "Find documentation here: https://github.com/atb00ker/terraform-kubernetes-openwisp/blob/master/docs/input.md."
}

variable "openwisp_deployments" {
  type = object({
    image_pull_policy = string
    restart_policy    = string
    dashboard = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    controller = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    radius = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    topology = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    nginx = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    postgres = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    postfix = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    freeradius = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    openvpn = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    openvpn = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    celery = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    celerybeat = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    redis = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
    websocket = object({
      replicas       = number
      image          = string
      limit_cpu      = number
      request_cpu    = number
      limit_memory   = string
      request_memory = string
    })
  })
  description = "Find documentation here: https://github.com/atb00ker/terraform-kubernetes-openwisp/blob/master/docs/input.md."
}
