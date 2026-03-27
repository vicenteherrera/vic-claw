variable "availability_domain" {
  description = "Availability domain for the instance"
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment OCID where the VM will be created"
  type        = string
}

variable "instance_name" {
  description = "VM display name"
  type        = string
}

variable "instance_shape" {
  description = "VM shape"
  type        = string
}

variable "subnet_id" {
  description = "Subnet OCID where the instance VNIC will be attached"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether the instance VNIC should receive a public IP"
  type        = bool
}

variable "ssh_public_key" {
  description = "Public SSH key content"
  type        = string
}

variable "image_ocid" {
  description = "Boot image OCID compatible with region and shape"
  type        = string
}