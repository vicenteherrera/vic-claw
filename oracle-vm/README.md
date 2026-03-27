# Oracle Always Free VM with Terraform

This folder contains Terraform configuration to create and destroy a small Oracle Cloud Always Free VM together with the OCI networking it needs.

## Files

- providers.tf: Terraform and OCI provider configuration (local backend in `private/`)
- network.tf: root module call for OCI networking
- compute.tf: root module call for OCI instance creation
- variables.tf: input variable definitions
- outputs.tf: instance and networking outputs
- terraform.tfvars.example: example input values
- modules/network: reusable OCI networking module
- modules/vm: reusable OCI VM module
- Makefile: helper targets (`make help` to list them all)

## Prerequisites

1. Terraform installed (v1.5+ recommended)
2. Oracle Cloud account with Always Free resources available
3. OCI API key configured (private key file and fingerprint)
4. A public SSH key to inject into instance metadata
5. (Optional) OCI CLI installed for helper targets like `validate-oci-login` and `print-account-tfvars`

## The `private/` folder

All sensitive and environment-specific files live inside `private/`:

| File | Purpose |
|------|---------|
| `terraform.tfvars` | Your real variable values (credentials, OCIDs, etc.) |
| `terraform.tfstate` | Terraform state (created automatically by the local backend) |
| `terraform.tfstate.backup` | Automatic state backup |
| `_empty` | Placeholder so the folder is tracked by git |

The `.gitignore` excludes everything in `private/` except the `_empty` placeholder. This means your credentials and state are never committed to the public repo. You can optionally manage `private/` as a separate private repository or keep it purely local.

## Configure variables

Copy the example file into `private/` and fill in your real values:

```bash
cp terraform.tfvars.example private/terraform.tfvars
```

Then edit `private/terraform.tfvars`:

```hcl
tenancy_ocid         = "ocid1.tenancy.oc1..example"
user_ocid            = "ocid1.user.oc1..example"
fingerprint          = "aa:bb:cc:dd:ee:ff:11:22:33:44:55:66:77:88:99:00"
private_key_path     = "~/.oci/oci_api_key.pem"
private_key_password = ""
region               = "us-ashburn-1"

compartment_ocid = "ocid1.compartment.oc1..example"
image_ocid       = "ocid1.image.oc1.iad.example"

# Contents of your SSH public key file
ssh_public_key   = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... yourname@host"

# Optional (defaults shown)
instance_name       = "always-free-vm"
instance_shape      = "VM.Standard.E2.1.Micro"
vcn_cidr_block      = "10.0.0.0/16"
subnet_cidr_block   = "10.0.0.0/24"
network_name_prefix = "always-free-vm"
ssh_ingress_cidr    = "0.0.0.0/0"
assign_public_ip    = true
```

Set `private_key_password` to the passphrase of your OCI API private key, or leave it empty if the key is unencrypted.

If you have the OCI CLI configured, you can auto-generate the account-related values:

```bash
make print-account-tfvars
```

To discover available image OCIDs for your region:

```bash
make get-image-ocid
```

If you want to reduce SSH exposure, set `ssh_ingress_cidr` to your current public IP range instead of `0.0.0.0/0`.

## Module structure

The root configuration delegates work to two reusable modules:

- **modules/network** creates the VCN, internet gateway, route table, security list, and subnet
- **modules/vm** creates the instance and resolves the primary VNIC public IP

Terraform creates these networking resources in the same compartment:

- one VCN
- one internet gateway
- one public route table with a default route to the internet gateway
- one security list that allows outbound traffic and inbound SSH on TCP 22
- one public subnet for the VM

## Usage

Run commands from this folder. List all available targets:

```bash
make help
```

### Update providers

```bash
make update-providers
```

### Preview changes

```bash
make plan-vm
```

### Create VM

```bash
make create-vm
```

Terraform will create the networking first and then create the VM inside the managed subnet.

### Destroy VM

```bash
make destroy-vm
```

## Get VM public IP

After creation:

```bash
make public-ip
```

Or directly via Terraform:

```bash
terraform output -raw public_ip
```

You can also retrieve the created network identifiers:

```bash
terraform output -raw vcn_id
terraform output -raw subnet_id
```

## Validate OCI credentials

Check that the OCI CLI is installed and your credentials work:

```bash
make validate-oci-login
```

Pass a different profile with `OCI_PROFILE=myprofile make validate-oci-login`.

## SSH into the VM

Use the private key that matches the public key in `ssh_public_key`.

If your image is Oracle Linux, user is usually `opc`:

```bash
ssh -i ~/.ssh/id_ed25519 opc@$(terraform output -raw public_ip)
```

If your image is Ubuntu, user is usually `ubuntu`:

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
