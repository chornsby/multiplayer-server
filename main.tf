terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    oci = {
      source  = "hashicorp/oci"
      version = "4.61.0"
    }
  }
}

provider "oci" {
  fingerprint      = var.fingerprint
  private_key_path = var.oracle_private_key_path
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
}

data "http" "icanhazip" {
  url = "https://icanhazip.com"
}
