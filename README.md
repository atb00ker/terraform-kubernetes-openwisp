# Terraform(kubernetes): OpenWISP

[![Terraform](https://img.shields.io/badge/terraform-openwisp-blue)](https://registry.terraform.io/modules/atb00ker/openwisp/kubernetes)
[![GitHub](https://img.shields.io/badge/github-openwisp-success)](https://github.com/openwisp/terraform-kubernetes-openwisp/)
[![GitHub license](https://img.shields.io/github/license/atb00ker/terraform-kubernetes-openwisp.svg)](https://github.com/openwisp/terraform-kubernetes-openwisp/blob/master/LICENSE)

Terraform files for deploying docker-openwisp in kubernetes.
This module does not provision the infrastructure but expects
access to an existing kubernetes cluster.

## Requirements

If you using the following options, please follow the requirements as per the variable's documentation:

- `kubernetes_services.use_cert_manager`

## Usage

**Note: The following links work only when you are viewing on github.com**

### Variables
- Inputs documentation available [here](docs/input.md).
- Outputs documentation available [here](docs/output.md).

### Examples
- Standalone example available [here](examples/standalone).
- Google cloud example available [here](examples/google-cloud).

### Create

1. Configure the options in the module. (`examples/` may be helpful)
2. Apply the configurations: `terraform apply`

### Destroy

1. Destroy the resources using terraform `terraform destroy`
2. Uninstall cert-manager: `kubectl delete --filename <kubernetes_services.cert_manager_link>`

## Advanced Usage

### Removing cert-manager

Unfortunately, cert-manager uses CRDs and terraform doesn't work very well with it, so if you want to remove

1. Destroy resources:

```bash
terraform destroy \
    --target=module.kubernetes.kubernetes_namespace.cert_manager \
    --target=module.kubernetes.null_resource.install_cert_manager \
    --target=module.kubernetes.null_resource.certificate_cert_manager \
    --target=module.kubernetes.null_resource.clusterissuer_cert_manager \
    --target=module.kubernetes.null_resource.ingress_cert_manager \
    --target=module.kubernetes.kubernetes_ingress.http_ingress
```

2. Uninstall cert-manager: `kubectl delete --filename <kubernetes_services.cert_manager_link>`

3. Create Ingress: `terraform apply --target=module.kubernetes.kubernetes_ingress.http_ingress`

## Contribute to documentation

1. Install MarkdownPP: `pip install MarkdownPP`
2. Make changes in `docs/build/` directory.
3. To create documentation, in the root of repository: `markdown-pp docs/build/input.mdpp -o docs/input.md`
