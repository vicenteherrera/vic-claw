variable "compartment_ocid" {
  description = "Compartment OCID where the network resources will be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for network resource display names"
  type        = string
}

variable "vcn_cidr_block" {
  description = "CIDR block for the VCN"
  type        = string
}

variable "subnet_cidr_block" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to reach the subnet over SSH"
  type        = string
}