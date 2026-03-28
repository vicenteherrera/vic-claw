# Ansible Runbooks

This folder contains Ansible playbooks for VM provisioning tasks.

## Files

- `install-podman-debian-ubuntu.yml`: Installs Podman on Debian / Ubuntu hosts.
- `install-podman-oraclelinux-rhel9.yml`: Installs Podman on Oracle Linux / RHEL 9.x hosts (legacy).
- `inventory.ini.example`: Example inventory for an Ubuntu VM.

## Quick start

1. Copy and edit the inventory:

```bash
cp ansible-runbook/inventory.ini.example ansible-runbook/inventory.ini
```

2. Update `ansible_host`, `ansible_user`, and key path in `ansible-runbook/inventory.ini`.

3. Validate SSH connectivity:

```bash
ansible -i ansible-runbook/inventory.ini ubuntu -m ping
```

4. Run the Podman install playbook:

```bash
ansible-playbook -i ansible-runbook/inventory.ini ansible-runbook/install-podman-debian-ubuntu.yml
```

## Optional: enable Podman API socket

```bash
ansible-playbook \
  -i ansible-runbook/inventory.ini \
  ansible-runbook/install-podman-debian-ubuntu.yml \
  -e "enable_podman_socket=true"
```

## Verify on target host

After the playbook completes:

```bash
podman --version
sudo systemctl status podman --no-pager || true
sudo systemctl status podman.socket --no-pager || true
```
