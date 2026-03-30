terraform {
  required_version = ">= 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }

  backend "local" {
    path = "private/terraform.tfstate"
  }
}

locals {
  expanded_private_key_path = (
    can(regex("^/", var.private_key_path))
    ? var.private_key_path
    : pathexpand("~/${var.private_key_path}")
  )
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = local.expanded_private_key_path
  private_key_password = var.private_key_password
  region           = var.region
}

locals {
  network_name_prefix = var.network_name_prefix != "" ? var.network_name_prefix : var.instance_name
}