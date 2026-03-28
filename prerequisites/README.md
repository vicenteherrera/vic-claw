# Prerequisites

This guide explains how to install and validate the tools required by the Terraform workflow in [oracle-vm/README.md](oracle-vm/README.md).

## What you need

1. Terraform (recommended: v1.5 or newer)
2. Oracle Cloud CLI (`oci`)
3. Ansible
4. SSH key pair (for VM access)

## macOS setup

### 1) Install Homebrew (if not installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Verify:

```bash
brew --version
```

### 2) Install Terraform

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

Verify:

```bash
terraform version
```

### 3) Install Oracle Cloud CLI

```bash
brew install oci-cli
```

Verify:

```bash
oci --version
```

### 4) Install Ansible

```bash
brew install ansible
```

Verify:

```bash
ansible --version
```

## Linux setup (Ubuntu/Debian)

### 1) Install Terraform

```bash
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
	sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
	sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install -y terraform
```

### 2) Install Oracle Cloud CLI

```bash
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
```

After install, restart your shell and verify:

```bash
oci --version
```

### 3) Install Ansible

```bash
sudo apt-get update
sudo apt-get install -y ansible
```

Verify:

```bash
ansible --version
```

## Configure Oracle Cloud CLI

Run interactive setup:

```bash
oci setup config
```

This creates [~/.oci/config](~/.oci/config) and typically an API key pair if you choose that option.

Minimum profile values you will need later in [oracle-vm/private/terraform.tfvars](oracle-vm/private/terraform.tfvars):

1. `user`
2. `tenancy`
3. `region`
4. `fingerprint`
5. `key_file`

Test access:

```bash
oci iam region-subscription list
```

## Create SSH key pair for VM access

If you do not already have a key pair:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "oracle-vm"
```

Your public key (`~/.ssh/id_ed25519.pub`) goes into `ssh_public_key` in Terraform variables.

## Quick preflight check

Run these commands before using the Terraform module:

```bash
terraform version
oci --version
ansible --version
ssh -V
```

From the [oracle-vm](oracle-vm) folder, you can also run:

```bash
make validate-oci-login
```

## Next step

Once prerequisites are installed and OCI is configured, continue with [oracle-vm/README.md](oracle-vm/README.md) to set `private/terraform.tfvars` and deploy the VM.

