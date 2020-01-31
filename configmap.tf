# ConfigMap resources, find documentation in
# official docker-openwisp repository.

resource "kubernetes_config_map" "kubes_postgres_configmap" {
  depends_on = [var.ow_cluster_ready]
  metadata { name = var.kubes_postgres_configmap.configmap_name }
  data = {
    POSTGRES_DB       = var.kubes_postgres_configmap.POSTGRES_DB
    POSTGRES_USER     = var.kubes_postgres_configmap.POSTGRES_USER
    POSTGRES_PASSWORD = var.kubes_postgres_configmap.POSTGRES_PASSWORD
  }
}

resource "kubernetes_config_map" "kubes_nfs_configmap" {
  depends_on = [var.ow_cluster_ready]
  metadata { name = var.kubes_nfs_configmap.configmap_name }
  data = {
    EXPORT_OPTS = var.kubes_nfs_configmap.EXPORT_OPTS
    EXPORT_DIR  = var.kubes_nfs_configmap.EXPORT_DIR
  }
}

resource "kubernetes_config_map" "kubes_common_configmap" {
  depends_on = [var.ow_cluster_ready]
  metadata { name = var.kubes_common_configmap.configmap_name }
  data = {
    DASHBOARD_DOMAIN                  = var.kubes_common_configmap.DASHBOARD_DOMAIN
    CONTROLLER_DOMAIN                 = var.kubes_common_configmap.CONTROLLER_DOMAIN
    RADIUS_DOMAIN                     = var.kubes_common_configmap.RADIUS_DOMAIN
    TOPOLOGY_DOMAIN                   = var.kubes_common_configmap.TOPOLOGY_DOMAIN
    EMAIL_DJANGO_DEFAULT              = var.kubes_common_configmap.EMAIL_DJANGO_DEFAULT
    DB_USER                           = var.kubes_common_configmap.DB_USER
    DB_PASS                           = var.kubes_common_configmap.DB_PASS
    DJANGO_SECRET_KEY                 = var.kubes_common_configmap.DJANGO_SECRET_KEY
    DJANGO_ALLOWED_HOSTS              = var.kubes_common_configmap.DJANGO_ALLOWED_HOSTS
    TZ                                = var.kubes_common_configmap.TZ
    CERT_ADMIN_EMAIL                  = var.kubes_common_configmap.CERT_ADMIN_EMAIL
    SSL_CERT_MODE                     = var.kubes_common_configmap.SSL_CERT_MODE
    SET_RADIUS_TASKS                  = var.kubes_common_configmap.SET_RADIUS_TASKS
    SET_TOPOLOGY_TASKS                = var.kubes_common_configmap.SET_TOPOLOGY_TASKS
    DB_NAME                           = var.kubes_common_configmap.DB_NAME
    DB_ENGINE                         = var.kubes_common_configmap.DB_ENGINE
    DB_PORT                           = var.kubes_common_configmap.DB_PORT
    DB_OPTIONS                        = var.kubes_common_configmap.DB_OPTIONS
    DJANGO_X509_DEFAULT_CERT_VALIDITY = var.kubes_common_configmap.DJANGO_X509_DEFAULT_CERT_VALIDITY
    DJANGO_X509_DEFAULT_CA_VALIDITY   = var.kubes_common_configmap.DJANGO_X509_DEFAULT_CA_VALIDITY
    DJANGO_CORS_ORIGIN_ALLOW_ALL      = var.kubes_common_configmap.DJANGO_CORS_ORIGIN_ALLOW_ALL
    DJANGO_LANGUAGE_CODE              = var.kubes_common_configmap.DJANGO_LANGUAGE_CODE
    DJANGO_SENTRY_DSN                 = var.kubes_common_configmap.DJANGO_SENTRY_DSN
    DJANGO_LEAFET_CENTER_X_AXIS       = var.kubes_common_configmap.DJANGO_LEAFET_CENTER_X_AXIS
    DJANGO_LEAFET_CENTER_Y_AXIS       = var.kubes_common_configmap.DJANGO_LEAFET_CENTER_Y_AXIS
    DJANGO_LEAFET_ZOOM                = var.kubes_common_configmap.DJANGO_LEAFET_ZOOM
    EMAIL_BACKEND                     = var.kubes_common_configmap.EMAIL_BACKEND
    EMAIL_HOST_PORT                   = var.kubes_common_configmap.EMAIL_HOST_PORT
    EMAIL_HOST_USER                   = var.kubes_common_configmap.EMAIL_HOST_USER
    EMAIL_HOST_PASSWORD               = var.kubes_common_configmap.EMAIL_HOST_PASSWORD
    EMAIL_HOST_TLS                    = var.kubes_common_configmap.EMAIL_HOST_TLS
    POSTFIX_ALLOWED_SENDER_DOMAINS    = var.kubes_common_configmap.POSTFIX_ALLOWED_SENDER_DOMAINS
    POSTFIX_MYHOSTNAME                = var.kubes_common_configmap.POSTFIX_MYHOSTNAME
    POSTFIX_DESTINATION               = var.kubes_common_configmap.POSTFIX_DESTINATION
    POSTFIX_MESSAGE_SIZE_LIMIT        = var.kubes_common_configmap.POSTFIX_MESSAGE_SIZE_LIMIT
    POSTFIX_MYNETWORKS                = var.kubes_common_configmap.POSTFIX_MYNETWORKS
    POSTFIX_RELAYHOST_TLS_LEVEL       = var.kubes_common_configmap.POSTFIX_RELAYHOST_TLS_LEVEL
    POSTFIX_RELAYHOST                 = var.kubes_common_configmap.POSTFIX_RELAYHOST
    POSTFIX_RELAYHOST_USERNAME        = var.kubes_common_configmap.POSTFIX_RELAYHOST_USERNAME
    POSTFIX_RELAYHOST_PASSWORD        = var.kubes_common_configmap.POSTFIX_RELAYHOST_PASSWORD
    FREERADIUS_ORGANIZATION           = var.kubes_common_configmap.FREERADIUS_ORGANIZATION
    FREERADIUS_KEY                    = var.kubes_common_configmap.FREERADIUS_KEY
    FREERADIUS_CLIENTS                = var.kubes_common_configmap.FREERADIUS_CLIENTS
    CRON_DELETE_OLD_RADACCT           = var.kubes_common_configmap.CRON_DELETE_OLD_RADACCT
    CRON_DELETE_OLD_POSTAUTH          = var.kubes_common_configmap.CRON_DELETE_OLD_POSTAUTH
    CRON_CLEANUP_STALE_RADACCT        = var.kubes_common_configmap.CRON_CLEANUP_STALE_RADACCT
    CRON_DELETE_OLD_USERS             = var.kubes_common_configmap.CRON_DELETE_OLD_USERS
    NGINX_HTTP2                       = var.kubes_common_configmap.NGINX_HTTP2
    NGINX_CLIENT_BODY_SIZE            = var.kubes_common_configmap.NGINX_CLIENT_BODY_SIZE
    NGINX_IP6_STRING                  = var.kubes_common_configmap.NGINX_IP6_STRING
    NGINX_IP6_80_STRING               = var.kubes_common_configmap.NGINX_IP6_80_STRING
    NGINX_ADMIN_ALLOW_NETWORK         = var.kubes_common_configmap.NGINX_ADMIN_ALLOW_NETWORK
    NGINX_SERVER_NAME_HASH_BUCKET     = var.kubes_common_configmap.NGINX_SERVER_NAME_HASH_BUCKET
    NGINX_SSL_CONFIG                  = var.kubes_common_configmap.NGINX_SSL_CONFIG
    NGINX_80_CONFIG                   = var.kubes_common_configmap.NGINX_80_CONFIG
    NGINX_GZIP_SWITCH                 = var.kubes_common_configmap.NGINX_GZIP_SWITCH
    NGINX_GZIP_LEVEL                  = var.kubes_common_configmap.NGINX_GZIP_LEVEL
    NGINX_GZIP_PROXIED                = var.kubes_common_configmap.NGINX_GZIP_PROXIED
    NGINX_GZIP_MIN_LENGTH             = var.kubes_common_configmap.NGINX_GZIP_MIN_LENGTH
    NGINX_GZIP_TYPES                  = var.kubes_common_configmap.NGINX_GZIP_TYPES
    NGINX_HTTPS_ALLOWED_IPS           = var.kubes_common_configmap.NGINX_HTTPS_ALLOWED_IPS
    NGINX_HTTP_ALLOW                  = var.kubes_common_configmap.NGINX_HTTP_ALLOW
    NGINX_CUSTOM_FILE                 = var.kubes_common_configmap.NGINX_CUSTOM_FILE
    NINGX_REAL_REMOTE_ADDR            = var.kubes_common_configmap.NINGX_REAL_REMOTE_ADDR
    VPN_ORG                           = var.kubes_common_configmap.VPN_ORG
    VPN_NAME                          = var.kubes_common_configmap.VPN_NAME
    VPN_CLIENT_NAME                   = var.kubes_common_configmap.VPN_CLIENT_NAME
    X509_NAME_CA                      = var.kubes_common_configmap.X509_NAME_CA
    X509_NAME_CERT                    = var.kubes_common_configmap.X509_NAME_CERT
    X509_COUNTRY_CODE                 = var.kubes_common_configmap.X509_COUNTRY_CODE
    X509_STATE                        = var.kubes_common_configmap.X509_STATE
    X509_CITY                         = var.kubes_common_configmap.X509_CITY
    X509_ORGANIZATION_NAME            = var.kubes_common_configmap.X509_ORGANIZATION_NAME
    X509_ORGANIZATION_UNIT_NAME       = var.kubes_common_configmap.X509_ORGANIZATION_UNIT_NAME
    X509_EMAIL                        = var.kubes_common_configmap.X509_EMAIL
    X509_COMMON_NAME                  = var.kubes_common_configmap.X509_COMMON_NAME
    DB_HOST                           = var.kubes_common_configmap.DB_HOST
    EMAIL_HOST                        = var.kubes_common_configmap.EMAIL_HOST
    REDIS_HOST                        = var.kubes_common_configmap.REDIS_HOST
    DASHBOARD_APP_SERVICE             = var.kubes_common_configmap.DASHBOARD_APP_SERVICE
    CONTROLLER_APP_SERVICE            = var.kubes_common_configmap.CONTROLLER_APP_SERVICE
    RADIUS_APP_SERVICE                = var.kubes_common_configmap.RADIUS_APP_SERVICE
    TOPOLOGY_APP_SERVICE              = var.kubes_common_configmap.TOPOLOGY_APP_SERVICE
    DEBUG_MODE                        = var.kubes_common_configmap.DEBUG_MODE
    DASHBOARD_APP_PORT                = var.kubes_common_configmap.DASHBOARD_APP_PORT
    CONTROLLER_APP_PORT               = var.kubes_common_configmap.CONTROLLER_APP_PORT
    RADIUS_APP_PORT                   = var.kubes_common_configmap.RADIUS_APP_PORT
    TOPOLOGY_APP_PORT                 = var.kubes_common_configmap.TOPOLOGY_APP_PORT
    DASHBOARD_URI                     = var.kubes_common_configmap.DASHBOARD_URI
    POSTFIX_DEBUG_MYNETWORKS          = var.kubes_common_configmap.POSTFIX_DEBUG_MYNETWORKS
  }
}
