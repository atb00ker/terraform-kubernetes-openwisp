# Google kubernetes Engine

This deployment example is for deploying OpenWISP on Google Kubernetes Engine.

## Requirements

1. Make sure you meet all requirements from [GCP module](https://github.com/atb00ker/terraform-gcp-openwisp#requirements)
2. Make sure you meet all requirements from [Kubernetes module](https://github.com/atb00ker/terraform-kubernetes-openwisp#requirements)
3. You will need "Compute Engine API - Backend services" to be atleast 7 for this deployment.

## Usage

### Create

1. Configure the options in the module. (`examples/google-cloud/module.tf` might be helpful)
2. Apply the configurations: `terraform apply`
3. Remember to set the NS records in your domain registrar before `cert-manager` start `http01` verification of the domain.

### Destroy

1. Destroy the resources using terraform `terraform destroy`
2. Remove Finalizers

GKE adds finalizers in persistent volumes claims to protect data from being accidentally deleted, remove these finalizers from the the volume claims **when** terraform is trying to destroy the claims:

```bash
$ kubectl get pvc --no-headers -o custom-columns=":metadata.name" |
    xargs kubectl patch pvc --patch '{"metadata":{"finalizers": null }}'
```
