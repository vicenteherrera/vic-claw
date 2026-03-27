# Uses the first availability domain in your region.
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

module "vm" {
  source = "./modules/vm"

  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_ocid    = var.compartment_ocid
  instance_name       = var.instance_name
  instance_shape      = var.instance_shape
  subnet_id           = module.network.subnet_id
  assign_public_ip    = var.assign_public_ip
  ssh_public_key      = var.ssh_public_key
  image_ocid          = var.image_ocid
}