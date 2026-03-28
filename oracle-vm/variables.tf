variable "tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
}

variable "user_ocid" {
  description = "OCI user OCID"
  type        = string
}

variable "fingerprint" {
  description = "API key fingerprint"
  type        = string
}

variable "private_key_path" {
  description = "Path to OCI API private key"
  type        = string
}

variable "private_key_password" {
  description = "OCI API private key password"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "OCI region, for example us-ashburn-1"
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where the VM will be created"
  type        = string
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN that Terraform will create"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the public subnet where the VM will be attached"
  type        = string
  default     = "10.0.0.0/24"
}

variable "network_name_prefix" {
  description = "Optional prefix for created network resource display names"
  type        = string
  default     = ""
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach the instance over SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "assign_public_ip" {
  description = "Whether the instance VNIC should receive a public IP"
  type        = bool
  default     = true
}

variable "image_ocid" {
  description = "Boot image OCID compatible with region and shape"
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH key content"
  type        = string
}

variable "instance_name" {
  description = "VM display name"
  type        = string
  default     = "always-free-vm"
}

variable "instance_shape" {
  description = "Always Free compatible shape (VM.Standard.E2.1.Micro for AMD, VM.Standard.A1.Flex for ARM)"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

variable "instance_ocpus" {
  description = "Number of OCPUs (required for Flex shapes like A1.Flex, null for fixed shapes)"
  type        = number
  default     = null
}

variable "instance_memory_in_gbs" {
  description = "Memory in GBs (required for Flex shapes like A1.Flex, null for fixed shapes)"
  type        = number
  default     = null
}