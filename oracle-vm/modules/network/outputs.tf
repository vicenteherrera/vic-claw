output "vcn_id" {
  description = "Created VCN OCID"
  value       = oci_core_vcn.this.id
}

output "subnet_id" {
  description = "Created public subnet OCID"
  value       = oci_core_subnet.public.id
}