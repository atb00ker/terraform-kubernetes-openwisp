# Entry point for terraform.

terraform {
  required_version = "~> 0.12.18"
  required_providers {
    kubernetes = "~> 1.10.0"
    null       = "~> 2.1.0"
  }
}

provider "kubernetes" {
  load_config_file       = false
  host                   = "https://${var.infrastructure.cluster.endpoint}"
  token                  = var.infrastructure.cluster.access_token
  cluster_ca_certificate = base64decode(var.infrastructure.cluster.ca_certificate)
}
