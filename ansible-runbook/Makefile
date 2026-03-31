ANSIBLE_INVENTORY ?= ../oracle-vm/private/inventory.ini
TERRAFORM_DIR ?= ../oracle-vm
PODMAN_RUNBOOK ?= install-podman-debian-ubuntu.yml

.PHONY: help
# Show available targets and their descriptions
help:
	@awk '/^# /{desc=substr($$0,3)} /^[a-zA-Z_-]+:/{if(desc){printf "  %-24s %s\n",$$1,desc; desc=""}}' $(MAKEFILE_LIST)

.PHONY: create-inventory-ini-ubuntu
# Generate private/inventory.ini with the VM public IP from terraform state
create-inventory-ini-ubuntu:
	@command -v terraform >/dev/null 2>&1 || { echo "Error: terraform not found in PATH"; exit 1; }
	@test -f $(TERRAFORM_DIR)/private/terraform.tfstate || { echo "Error: terraform.tfstate not found in $(TERRAFORM_DIR)/private/"; exit 1; }
	$(eval IP := $(shell terraform -chdir=$(TERRAFORM_DIR) output -state=private/terraform.tfstate -raw public_ip))
	@test -n "$(IP)" || { echo "Error: could not extract public_ip from terraform state"; exit 1; }
	@mkdir -p $(dir $(ANSIBLE_INVENTORY))
	@printf '[ubuntu]\noracle-vm ansible_host=%s ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_ed25519\n\n[ubuntu:vars]\nansible_python_interpreter=/usr/bin/python3\n' "$(IP)" > $(ANSIBLE_INVENTORY)
	@echo "Inventory written to $(ANSIBLE_INVENTORY) (IP=$(IP))"

.PHONY: create-inventory-ini-oracle-linux
# Generate private/inventory.ini with the VM public IP from terraform state for Oracle Linux
create-inventory-ini-oracle-linux:
	@command -v terraform >/dev/null 2>&1 || { echo "Error: terraform not found in PATH"; exit 1; }
	@test -f $(TERRAFORM_DIR)/private/terraform.tfstate || { echo "Error: terraform.tfstate not found in $(TERRAFORM_DIR)/private/"; exit 1; }
	$(eval IP := $(shell terraform -chdir=$(TERRAFORM_DIR) output -state=private/terraform.tfstate -raw public_ip))
	@test -n "$(IP)" || { echo "Error: could not extract public_ip from terraform state"; exit 1; }
	@mkdir -p $(dir $(ANSIBLE_INVENTORY))
	@printf '[oracle_linux]\noracle-vm ansible_host=%s ansible_user=opc ansible_ssh_private_key_file=~/.ssh/id_ed25519\n\n[oracle_linux:vars]\nansible_python_interpreter=/usr/bin/python3\n' "$(IP)" > $(ANSIBLE_INVENTORY)
	@echo "Inventory written to $(ANSIBLE_INVENTORY) (IP=$(IP))"

.PHONY: apply-podman-runbook
# Apply Podman installation runbook using inventory from oracle-vm/private
apply-podman-runbook: verify-podman-runbook
	ansible-playbook -i $(ANSIBLE_INVENTORY) $(PODMAN_RUNBOOK)

.PHONY: apply-prerequisites
# Apply Python3, pip, git, sudo and systemd --user lingering installation playbook using inventory from oracle-vm/private
apply-prerequisites:
	ansible-playbook -i $(ANSIBLE_INVENTORY) install-openclaw-cli-prerequisites.yml

.PHONY: verify-podman-runbook
# Verify Podman installation runbook syntax using inventory from oracle-vm/private
verify-podman-runbook:
	@command -v ansible-playbook >/dev/null 2>&1 || { echo "Error: ansible-playbook not found in PATH"; exit 1; }
	@test -f $(ANSIBLE_INVENTORY) || { echo "Error: inventory file not found at $(ANSIBLE_INVENTORY)"; exit 1; }
	@test -f $(PODMAN_RUNBOOK) || { echo "Error: runbook not found at $(PODMAN_RUNBOOK)"; exit 1; }
	ansible-playbook --syntax-check -i $(ANSIBLE_INVENTORY) $(PODMAN_RUNBOOK)

.PHONY: apply-openclaw-cli
# Apply openclaw CLI installation playbook using inventory from oracle-vm/private
apply-openclaw-cli:
	ansible-playbook -i $(ANSIBLE_INVENTORY) install-openclaw-cli.yml
