ANSIBLE_INVENTORY ?= ../oracle-vm/private/inventory.ini
PODMAN_RUNBOOK ?= install-podman-debian-ubuntu.yml

.PHONY: help
# Show available targets and their descriptions
help:
	@awk '/^# /{desc=substr($$0,3)} /^[a-zA-Z_-]+:/{if(desc){printf "  %-24s %s\n",$$1,desc; desc=""}}' $(MAKEFILE_LIST)

.PHONY: apply-podman-runbook
# Apply Podman installation runbook using inventory from oracle-vm/private
apply-podman-runbook: verify-podman-runbook
	ansible-playbook -i $(ANSIBLE_INVENTORY) $(PODMAN_RUNBOOK)

.PHONY: verify-podman-runbook
# Verify Podman installation runbook syntax using inventory from oracle-vm/private
verify-podman-runbook:
	@command -v ansible-playbook >/dev/null 2>&1 || { echo "Error: ansible-playbook not found in PATH"; exit 1; }
	@test -f $(ANSIBLE_INVENTORY) || { echo "Error: inventory file not found at $(ANSIBLE_INVENTORY)"; exit 1; }
	@test -f $(PODMAN_RUNBOOK) || { echo "Error: runbook not found at $(PODMAN_RUNBOOK)"; exit 1; }
	ansible-playbook --syntax-check -i $(ANSIBLE_INVENTORY) $(PODMAN_RUNBOOK)
