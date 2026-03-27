module "network" {
  source = "./modules/network"

  compartment_ocid  = var.compartment_ocid
  name_prefix       = local.network_name_prefix
  vcn_cidr_block    = var.vcn_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  ssh_ingress_cidr  = var.ssh_ingress_cidr
}