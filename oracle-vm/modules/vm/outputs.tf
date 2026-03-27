output "instance_id" {
  description = "Created instance OCID"
  value       = oci_core_instance.this.id
}

output "public_ip" {
  description = "Public IP of the instance"
  value       = data.oci_core_vnic.primary.public_ip_address
}