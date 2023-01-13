terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.3.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "4.103.0"
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
  url = "https://ipv4.icanhazip.com"
}
