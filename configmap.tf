# ConfigMap resources, find documentation in
# official docker-openwisp repository.

resource "kubernetes_config_map" "kubernetes_postgres_configmap" {
  depends_on = [var.ow_cluster_ready]
  metadata { name = var.kubernetes_configmap.postgres_configmap_name }
  data = {
    POSTGRES_DB       = var.kubernetes_configmap.DB_NAME
    POSTGRES_USER     = var.kubernetes_configmap.DB_USER
    POSTGRES_PASSWORD = var.kubernetes_configmap.DB_PASS
  }
}

resource "kubernetes_config_map" "kubernetes_nfs_configmap" {
  depends_on = [var.ow_cluster_ready]
  metadata {
    name      = var.kubernetes_configmap.nfs_configmap_name
    namespace = kubernetes_namespace.nfs_server.metadata[0].name
  }
  data = {
    EXPORT_OPTS = var.kubernetes_configmap.EXPORT_OPTS
    EXPORT_DIR  = var.kubernetes_configmap.EXPORT_DIR
  }
}

resource "kubernetes_config_map" "kubernetes_common_configmap" {
  depends_on = [var.ow_cluster_ready]
  metadata { name = var.kubernetes_configmap.common_configmap_name }
  data = {
    DASHBOARD_DOMAIN                  = var.kubernetes_configmap.DASHBOARD_DOMAIN
    CONTROLLER_DOMAIN                 = var.kubernetes_configmap.CONTROLLER_DOMAIN
    RADIUS_DOMAIN                     = var.kubernetes_configmap.RADIUS_DOMAIN
    TOPOLOGY_DOMAIN                   = var.kubernetes_configmap.TOPOLOGY_DOMAIN
    EMAIL_DJANGO_DEFAULT              = var.kubernetes_configmap.EMAIL_DJANGO_DEFAULT
    DJANGO_SECRET_KEY                 = var.kubernetes_configmap.DJANGO_SECRET_KEY
    DJANGO_ALLOWED_HOSTS              = var.kubernetes_configmap.DJANGO_ALLOWED_HOSTS
    TZ                                = var.kubernetes_configmap.TZ
    CERT_ADMIN_EMAIL                  = var.kubernetes_configmap.CERT_ADMIN_EMAIL
    SSL_CERT_MODE                     = var.kubernetes_configmap.SSL_CERT_MODE
    SET_RADIUS_TASKS                  = var.kubernetes_configmap.SET_RADIUS_TASKS
    SET_TOPOLOGY_TASKS                = var.kubernetes_configmap.SET_TOPOLOGY_TASKS
    DB_NAME                           = var.kubernetes_configmap.DB_NAME
    DB_USER                           = var.kubernetes_configmap.DB_USER
    DB_PASS                           = var.kubernetes_configmap.DB_PASS
    DB_ENGINE                         = var.kubernetes_configmap.DB_ENGINE
    DB_PORT                           = var.kubernetes_configmap.DB_PORT
    DB_OPTIONS                        = var.kubernetes_configmap.DB_OPTIONS
    DJANGO_X509_DEFAULT_CERT_VALIDITY = var.kubernetes_configmap.DJANGO_X509_DEFAULT_CERT_VALIDITY
    DJANGO_X509_DEFAULT_CA_VALIDITY   = var.kubernetes_configmap.DJANGO_X509_DEFAULT_CA_VALIDITY
    DJANGO_CORS_ORIGIN_ALLOW_ALL      = var.kubernetes_configmap.DJANGO_CORS_ORIGIN_ALLOW_ALL
    DJANGO_LANGUAGE_CODE              = var.kubernetes_configmap.DJANGO_LANGUAGE_CODE
    DJANGO_SENTRY_DSN                 = var.kubernetes_configmap.DJANGO_SENTRY_DSN
    DJANGO_LEAFET_CENTER_X_AXIS       = var.kubernetes_configmap.DJANGO_LEAFET_CENTER_X_AXIS
    DJANGO_LEAFET_CENTER_Y_AXIS       = var.kubernetes_configmap.DJANGO_LEAFET_CENTER_Y_AXIS
    DJANGO_LEAFET_ZOOM                = var.kubernetes_configmap.DJANGO_LEAFET_ZOOM
    EMAIL_BACKEND                     = var.kubernetes_configmap.EMAIL_BACKEND
    EMAIL_HOST_PORT                   = var.kubernetes_configmap.EMAIL_HOST_PORT
    EMAIL_HOST_USER                   = var.kubernetes_configmap.EMAIL_HOST_USER
    EMAIL_HOST_PASSWORD               = var.kubernetes_configmap.EMAIL_HOST_PASSWORD
    EMAIL_HOST_TLS                    = var.kubernetes_configmap.EMAIL_HOST_TLS
    POSTFIX_ALLOWED_SENDER_DOMAINS    = var.kubernetes_configmap.POSTFIX_ALLOWED_SENDER_DOMAINS
    POSTFIX_MYHOSTNAME                = var.kubernetes_configmap.POSTFIX_MYHOSTNAME
    POSTFIX_DESTINATION               = var.kubernetes_configmap.POSTFIX_DESTINATION
    POSTFIX_MESSAGE_SIZE_LIMIT        = var.kubernetes_configmap.POSTFIX_MESSAGE_SIZE_LIMIT
    POSTFIX_MYNETWORKS                = var.kubernetes_configmap.POSTFIX_MYNETWORKS
    POSTFIX_RELAYHOST_TLS_LEVEL       = var.kubernetes_configmap.POSTFIX_RELAYHOST_TLS_LEVEL
    POSTFIX_RELAYHOST                 = var.kubernetes_configmap.POSTFIX_RELAYHOST
    POSTFIX_RELAYHOST_USERNAME        = var.kubernetes_configmap.POSTFIX_RELAYHOST_USERNAME
    POSTFIX_RELAYHOST_PASSWORD        = var.kubernetes_configmap.POSTFIX_RELAYHOST_PASSWORD
    FREERADIUS_ORGANIZATION           = var.kubernetes_configmap.FREERADIUS_ORGANIZATION
    FREERADIUS_KEY                    = var.kubernetes_configmap.FREERADIUS_KEY
    FREERADIUS_CLIENTS                = var.kubernetes_configmap.FREERADIUS_CLIENTS
    CRON_DELETE_OLD_RADACCT           = var.kubernetes_configmap.CRON_DELETE_OLD_RADACCT
    CRON_DELETE_OLD_POSTAUTH          = var.kubernetes_configmap.CRON_DELETE_OLD_POSTAUTH
    CRON_CLEANUP_STALE_RADACCT        = var.kubernetes_configmap.CRON_CLEANUP_STALE_RADACCT
    CRON_DELETE_OLD_USERS             = var.kubernetes_configmap.CRON_DELETE_OLD_USERS
    NGINX_HTTP2                       = var.kubernetes_configmap.NGINX_HTTP2
    NGINX_CLIENT_BODY_SIZE            = var.kubernetes_configmap.NGINX_CLIENT_BODY_SIZE
    NGINX_IP6_STRING                  = var.kubernetes_configmap.NGINX_IP6_STRING
    NGINX_IP6_80_STRING               = var.kubernetes_configmap.NGINX_IP6_80_STRING
    NGINX_ADMIN_ALLOW_NETWORK         = var.kubernetes_configmap.NGINX_ADMIN_ALLOW_NETWORK
    NGINX_SERVER_NAME_HASH_BUCKET     = var.kubernetes_configmap.NGINX_SERVER_NAME_HASH_BUCKET
    NGINX_SSL_CONFIG                  = var.kubernetes_configmap.NGINX_SSL_CONFIG
    NGINX_80_CONFIG                   = var.kubernetes_configmap.NGINX_80_CONFIG
    NGINX_GZIP_SWITCH                 = var.kubernetes_configmap.NGINX_GZIP_SWITCH
    NGINX_GZIP_LEVEL                  = var.kubernetes_configmap.NGINX_GZIP_LEVEL
    NGINX_GZIP_PROXIED                = var.kubernetes_configmap.NGINX_GZIP_PROXIED
    NGINX_GZIP_MIN_LENGTH             = var.kubernetes_configmap.NGINX_GZIP_MIN_LENGTH
    NGINX_GZIP_TYPES                  = var.kubernetes_configmap.NGINX_GZIP_TYPES
    NGINX_HTTPS_ALLOWED_IPS           = var.kubernetes_configmap.NGINX_HTTPS_ALLOWED_IPS
    NGINX_HTTP_ALLOW                  = var.kubernetes_configmap.NGINX_HTTP_ALLOW
    NGINX_CUSTOM_FILE                 = var.kubernetes_configmap.NGINX_CUSTOM_FILE
    NINGX_REAL_REMOTE_ADDR            = var.kubernetes_configmap.NINGX_REAL_REMOTE_ADDR
    VPN_ORG                           = var.kubernetes_configmap.VPN_ORG
    VPN_NAME                          = var.kubernetes_configmap.VPN_NAME
    VPN_CLIENT_NAME                   = var.kubernetes_configmap.VPN_CLIENT_NAME
    X509_NAME_CA                      = var.kubernetes_configmap.X509_NAME_CA
    X509_NAME_CERT                    = var.kubernetes_configmap.X509_NAME_CERT
    X509_COUNTRY_CODE                 = var.kubernetes_configmap.X509_COUNTRY_CODE
    X509_STATE                        = var.kubernetes_configmap.X509_STATE
    X509_CITY                         = var.kubernetes_configmap.X509_CITY
    X509_ORGANIZATION_NAME            = var.kubernetes_configmap.X509_ORGANIZATION_NAME
    X509_ORGANIZATION_UNIT_NAME       = var.kubernetes_configmap.X509_ORGANIZATION_UNIT_NAME
    X509_EMAIL                        = var.kubernetes_configmap.X509_EMAIL
    X509_COMMON_NAME                  = var.kubernetes_configmap.X509_COMMON_NAME
    DB_HOST                           = var.kubernetes_configmap.DB_HOST
    EMAIL_HOST                        = var.kubernetes_configmap.EMAIL_HOST
    REDIS_HOST                        = var.kubernetes_configmap.REDIS_HOST
    DASHBOARD_APP_SERVICE             = var.kubernetes_configmap.DASHBOARD_APP_SERVICE
    CONTROLLER_APP_SERVICE            = var.kubernetes_configmap.CONTROLLER_APP_SERVICE
    RADIUS_APP_SERVICE                = var.kubernetes_configmap.RADIUS_APP_SERVICE
    TOPOLOGY_APP_SERVICE              = var.kubernetes_configmap.TOPOLOGY_APP_SERVICE
    DEBUG_MODE                        = var.kubernetes_configmap.DEBUG_MODE
    DASHBOARD_APP_PORT                = var.kubernetes_configmap.DASHBOARD_APP_PORT
    CONTROLLER_APP_PORT               = var.kubernetes_configmap.CONTROLLER_APP_PORT
    RADIUS_APP_PORT                   = var.kubernetes_configmap.RADIUS_APP_PORT
    TOPOLOGY_APP_PORT                 = var.kubernetes_configmap.TOPOLOGY_APP_PORT
    DASHBOARD_URI                     = var.kubernetes_configmap.DASHBOARD_URI
    POSTFIX_DEBUG_MYNETWORKS          = var.kubernetes_configmap.POSTFIX_DEBUG_MYNETWORKS
  }
}
