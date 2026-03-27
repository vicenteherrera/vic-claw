output "instance_id" {
  description = "Created instance OCID"
  value       = module.vm.instance_id
}

output "vcn_id" {
  description = "Created VCN OCID"
  value       = module.network.vcn_id
}

output "subnet_id" {
  description = "Created subnet OCID"
  value       = module.network.subnet_id
}

output "public_ip" {
  description = "Public IP of the instance"
  value       = module.vm.public_ip
}