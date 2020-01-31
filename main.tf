# Entry point for terraform.

terraform {
  required_version = "~> 0.12.6"
  required_providers {
    kubernetes = "~> 1.10"
    null       = "~> 2.1"
  }
}

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${var.infrastructure_provider.cluster.endpoint}"
  token                  = var.infrastructure_provider.cluster.access_token
  cluster_ca_certificate = base64decode(var.infrastructure_provider.cluster.ca_certificate)
}
