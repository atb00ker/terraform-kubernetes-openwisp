# Input Variables

The `eight` input variables are docuemented below:

1\.  [infrastructure](#infrastructure)  
2\.  [kubernetes_services](#kubernetes_services)  
3\.  [ow_cluster_ready](#ow_cluster_ready)  
4\.  [ow_kubectl_ready](#ow_kubectl_ready)  
5\.  [openwisp_services](#openwisp_services)  
6\.  [persistent_data](#persistent_data)  
7\.  [kubernetes_configmap](#kubernetes_configmap)  
8\.  [openwisp_deployments](#openwisp_deployments)  

<a name="infrastructure"></a>

### 1\. infrastructure

Details about the infrastructure.

```
name                            : Name of the provider.
                                  Valid options are: ["google",]
http_loadbalancer_name          : Name of the http_loadbalancer. (Useful for annotations in kubernetes Ingress)
openvpn_loadbalancer_address    : IP Address to be assigned for openvpn kubernetes loadbalancer.
freeradius_loadbalancer_address : IP Address to be assigned for freeradius kubernetes loadbalancer.
cluster:
name                            : Name of the kubernetes cluster.
nodes_cidr_range                : Address range for pods.
pods_cidr_range                 : Address range for pods.
services_cidr_range             : Address range for ClusterIP services.
endpoint                        : Kubernetes cluster endpoint IP address. (example: 192.168.2.25)
ca_certificate                  : ca_certificate of the cluster that needs to be decoded in base64 for authentication.
access_token                    : Access token required for authentication to perform actions in the cluster.
database:
enabled                         : Flag for cloud provided database being used. (Like Google Cloud SQL)
sslmode                         : [PSQL database sslmodes](https://www.postgresql.org/docs/9.1/libpq-ssl.html)
ca_cert                         : Contents of the server certificate file
client_cert                     : Contents of the client certificate file
client_key                      : Contents of the client private key
username                        : Username to login to database
password                        : Password to login to database
name                            : Name of the database to be used by openwisp
host                            : IP address of the database server
```
<a name="kubernetes_services"></a>

### 2\. kubernetes_services

Configuration for OpenWISP kubernetes services.

```
use_cert_manger   : (Boolean) Install cert-manager and get TLS certificates for the Ingress.
                      1. You need `kubectl` pre-configured on your machine.
                      2. Your domain should be pointing at your Ingress's IP for http01 validation.
                      3. If used with GCP module, "gcloud_configure" option might be helpful.
cert_manager_link : Link of YAML file to use to install cert-manager.
```
<a name="ow_cluster_ready"></a>

### 3\. ow_cluster_ready

(Boolean) Resource creation starts when this signal is received, useful for other modules to report when cluster is ready for deployment.
<a name="ow_kubectl_ready"></a>

### 4\. ow_kubectl_ready

(Boolean) Signal for kubectl configured and ready on local machine.
<a name="openwisp_services"></a>

### 5\. openwisp_services

Flags for enabling/disabling OpenWISP services to be used.

```
use_openvpn    : (Boolean) Setup OpenVPN for management inside cluster.
use_freeradius : (Boolean) Setup freeradius inside cluster.
setup_database : (Boolean) Setup database inside cluster. You would want to
                    set this as false when you have your own database server or
                    you are using cloud SQL.
setup_fresh    : (Boolean) Flag to initial setup of openwisp. Only required when you
                    are setting up openwisp & openwisp-database for the first time.
```
<a name="persistent_data"></a>

### 6\. persistent_data

Persistent storage information for the cluster.

```
name                         : https://www.terraform.io/docs/providers/google/r/compute_disk.html#name
type                         : https://www.terraform.io/docs/providers/google/r/compute_disk.html#type
size                         : https://www.terraform.io/docs/providers/google/r/compute_disk.html#size
reclaim_policy               : https://www.terraform.io/docs/providers/kubernetes/r/storage_class.html#reclaim_policy
postgres_storage_size        : Disk size portion to be allocated for postgres database.
sslcert_storage_size         : Disk size portion to be allocated for storing postfix sslcert data.
media_storage_size           : Disk size portion to be allocated for user uploaded media (like floor plan).
static_storage_size          : Disk size portion to be allocated for static data of the website.
html_storage_size            : Disk size portion to be allocated for maintaince HTML.
nfs_server:
internal_ip                  : Valid ClusterIP to be reserved for NFS server.
limit_cpu                    : CPU limit for the pod
requests_cpu                 : Minimum CPU requirement for the pod
limit_memory                 : Memory limit for the pod
requests_memory              : Minimum memory requirement for the pod
```
<a name="kubernetes_configmap"></a>

### 7\. kubernetes_configmap

Options for configmaps are the same as the one available for docker-openwisp image [environment options](https://github.com/openwisp/docker-openwisp/blob/master/docs/ENV.md)

However, some database options are set in the infrastructure variable.
<a name="openwisp_deployments"></a>

### 8\. openwisp_deployments

Basic options for all the OpenWISP deployment containers.

```
image_pull_policy   : https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#image_pull_policy
restart_policy      : https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#restart_policy
dashboard:
    replicas        : https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#replicas
    image           : https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#image
    limit_cpu       : CPU limit for each pod
    requests_cpu    : Minimum CPU requirement for each pod
    limit_memory    : Memory limit for each pod
    requests_memory : Minimum memory requirement for each pod
controller:  **Same as dashboard options
radius:      **Same as dashboard options
topology:    **Same as dashboard options
celery:      **Same as dashboard options
celerybeat:  **Same as dashboard options
nginx:       **Same as dashboard options
websocket:   **Same as dashboard options
freeradius:  **Same as dashboard options
openvpn:     **Same as dashboard options
postfix:     **Same as dashboard options
postgres:    **Same as dashboard options
redis:       **Same as dashboard options
```
