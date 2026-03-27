# Oracle Always Free VM with Terraform

This folder contains Terraform configuration to create and destroy a small Oracle Cloud Always Free VM together with the OCI networking it needs.

## Files

- providers.tf: Terraform and OCI provider configuration
- network.tf: root module call for OCI networking
- compute.tf: root module call for OCI instance creation
- variables.tf: input variable definitions
- outputs.tf: instance and networking outputs
- terraform.tfvars.example: example input values for local use
- modules/network: reusable OCI networking module
- modules/vm: reusable OCI VM module
- Makefile: helper targets for provider updates, create, and destroy

## Prerequisites

1. Terraform installed (v1.5+ recommended)
2. Oracle Cloud account with Always Free resources available
3. OCI API key configured (private key file and fingerprint)
4. A public SSH key to inject into instance metadata

## Configure variables

Copy terraform.tfvars.example to terraform.tfvars in this folder and fill in your real values.

Example:

```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..example"
user_ocid        = "ocid1.user.oc1..example"
fingerprint      = "aa:bb:cc:dd:ee:ff:11:22:33:44:55:66:77:88:99:00"
private_key_path = "~/.oci/oci_api_key.pem"
region           = "us-ashburn-1"

compartment_ocid = "ocid1.compartment.oc1..example"
image_ocid       = "ocid1.image.oc1.iad.example"

# Contents of your SSH public key file
ssh_public_key   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... yourname@host"

# Optional (defaults shown)
instance_name    = "always-free-vm"
instance_shape   = "VM.Standard.E2.1.Micro"
vcn_cidr_block   = "10.0.0.0/16"
subnet_cidr_block = "10.0.0.0/24"
network_name_prefix = "always-free-vm"
ssh_ingress_cidr = "0.0.0.0/0"
assign_public_ip = true
```

Terraform now creates these networking resources in the same compartment:

- one VCN
- one internet gateway
- one public route table with a default route to the internet gateway
- one security list that allows outbound traffic and inbound SSH on TCP 22
- one public subnet for the VM

If you want to reduce exposure, set ssh_ingress_cidr to your current public IP range instead of 0.0.0.0/0.

## Module structure

The root configuration keeps the same inputs and outputs, but now delegates work to two reusable modules:

- modules/network creates the VCN, internet gateway, route table, security list, and subnet
- modules/vm creates the instance and resolves the primary VNIC public IP

## Usage

Run commands from this folder.

Update providers:

```bash
make update-providers
```

Create VM:

```bash
make create-vm
```

Terraform will create the networking first and then create the VM inside the managed subnet.

Destroy VM:

```bash
make destroy-vm
```

## Get VM public IP

After creation:

```bash
terraform output -raw public_ip
```

You can also retrieve the created network identifiers:

```bash
terraform output -raw vcn_id
terraform output -raw subnet_id
```

## SSH into the VM

Use the private key that matches the public key in ssh_public_key.

If your image is Oracle Linux, user is usually opc:

```bash
ssh -i ~/.ssh/id_ed25519 opc@$(terraform output -raw public_ip)
```

If your image is Ubuntu, user is usually ubuntu:

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@$(terraform output -raw public_ip)
```

If SSH fails:

1. Confirm your subnet/security list allows inbound TCP 22
2. Confirm the correct username for the image
3. Confirm your local private key matches the injected public key
4. Try once with verbose SSH logs:

```bash
ssh -vvv -i ~/.ssh/id_ed25519 opc@$(terraform output -raw public_ip)
```
