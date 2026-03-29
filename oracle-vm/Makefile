# Retry create-vm every 10 minutes until it succeeds, printing retry count and elapsed time
.PHONY: retry-create-vm
retry-create-vm:
	@retries=0; start_time=$$(date +%s); \
	while true; do \
	  echo "[Attempt $$((retries+1))] Starting create-vm at $$(date)"; \
	  if $(MAKE) create-vm; then \
	    elapsed=$$(( $$(date +%s) - start_time )); \
	    echo "SUCCESS after $$((retries+1)) attempt(s), elapsed: $$((elapsed/60))m $$((elapsed%60))s"; \
	    break; \
	  else \
	    elapsed=$$(( $$(date +%s) - start_time )); \
	    echo "[Attempt $$((retries+1)) FAILED] Elapsed: $$((elapsed/60))m $$((elapsed%60))s. Retrying in 5 minutes..."; \
	    retries=$$((retries+1)); \
	    sleep 300; \
	  fi; \
	done
TF ?= terraform
TFVARS ?= private/terraform.tfvars
OCI ?= oci
OCI_PROFILE ?= DEFAULT

.PHONY: help
# Show available targets and their descriptions
help:
	@awk '/^# /{desc=substr($$0,3)} /^[a-zA-Z_-]+:/{if(desc){printf "  %-22s %s\n",$$1,desc; desc=""}}' $(MAKEFILE_LIST)

.PHONY: update-providers
# Upgrade Terraform providers to latest compatible versions
update-providers:
	$(TF) init -upgrade

.PHONY: plan-vm
# Preview infrastructure changes without applying them
plan-vm:
	$(TF) init
	$(TF) plan -var-file=$(TFVARS)

.PHONY: create-vm
# Create or update the VM and all associated resources
create-vm:
	$(TF) init
	$(TF) apply -var-file=$(TFVARS) -auto-approve

.PHONY: destroy-vm
# Tear down all Terraform-managed infrastructure
destroy-vm:
	$(TF) init
	$(TF) destroy -var-file=$(TFVARS)

.PHONY: public-ip
# Get the public IP address of the VM from Terraform output
public-ip:
	@echo "$$($(TF) output -raw public_ip)"

.PHONY: ssh-command
# Print the SSH command to connect to the VM
ssh-command:
	@echo "ssh opc@$$($(TF) output -raw public_ip)"

.PHONY: validate-oci-login
# Verify that OCI CLI is installed and credentials are valid
validate-oci-login:
	@command -v $(OCI) >/dev/null 2>&1 || { echo "Error: oci-cli not found in PATH"; exit 1; }
	@echo "Validating OCI CLI credentials with profile: $(OCI_PROFILE)"
	@$(OCI) iam user get --user-id $$($(OCI) iam user list --profile $(OCI_PROFILE) --query 'data[0].id' --raw-output --profile $(OCI_PROFILE)) --profile $(OCI_PROFILE) >/dev/null 2>&1 && echo "✓ OCI CLI login successful" || { echo "✗ OCI CLI login failed"; exit 1; }

.PHONY: print-account-tfvars
# Extract OCI account details and print them as tfvars
print-account-tfvars:
	@command -v $(OCI) >/dev/null 2>&1 || { echo "Error: oci-cli not found in PATH"; exit 1; }
	@CFG_FILE="$${OCI_CLI_CONFIG_FILE:-$$HOME/.oci/config}"; \
	read_cfg_value() { \
		awk -v profile="$(OCI_PROFILE)" -v key="$$1" '\
			/^\[/ { in_profile = ($$0 == "[" profile "]") } \
			in_profile && $$0 ~ "^[[:space:]]*" key "[[:space:]]*=" { \
				sub("^[^=]*=[[:space:]]*", "", $$0); \
				gsub(/^[[:space:]]+|[[:space:]]+$$/, "", $$0); \
				print $$0; \
				exit; \
			} \
		' "$$CFG_FILE"; \
	}; \
	clean_or_placeholder() { \
		if [ -n "$$1" ] && [ "$$1" != "null" ]; then \
			printf '%s' "$$1"; \
		else \
			printf '<set-me>'; \
		fi; \
	}; \
	TENANCY_OCID="$$($(OCI) iam availability-domain list --profile $(OCI_PROFILE) --all --query 'data[0]."compartment-id"' --raw-output 2>/dev/null || true)"; \
	USER_OCID="$$(read_cfg_value user)"; \
	FINGERPRINT="$$(read_cfg_value fingerprint)"; \
	PRIVATE_KEY_PATH="$$(read_cfg_value key_file)"; \
	REGION="$$(read_cfg_value region)"; \
	COMPARTMENT_OCID="$$($(OCI) iam compartment list --profile $(OCI_PROFILE) --compartment-id "$$TENANCY_OCID" --access-level ACCESSIBLE --all --query 'data[?"lifecycle-state"==`ACTIVE` && name!=`ManagedCompartmentForPaaS`] | [0].id' --raw-output 2>/dev/null || true)"; \
	if [ -z "$$COMPARTMENT_OCID" ] || [ "$$COMPARTMENT_OCID" = "null" ]; then COMPARTMENT_OCID="$$TENANCY_OCID"; fi; \
	printf 'tenancy_ocid     = "%s"\n' "$$(clean_or_placeholder "$$TENANCY_OCID")"; \
	printf 'user_ocid        = "%s"\n' "$$(clean_or_placeholder "$$USER_OCID")"; \
	printf 'fingerprint      = "%s"\n' "$$(clean_or_placeholder "$$FINGERPRINT")"; \
	printf 'private_key_path = "%s"\n' "$$(clean_or_placeholder "$$PRIVATE_KEY_PATH")"; \
	printf 'region           = "%s"\n' "$$(clean_or_placeholder "$$REGION")"; \
	printf 'compartment_ocid = "%s"\n' "$$(clean_or_placeholder "$$COMPARTMENT_OCID")"

.PHONY: get-image-ocid
# List available Ubuntu/Oracle Linux image OCIDs for the region
get-image-ocid:
	@command -v $(OCI) >/dev/null 2>&1 || { echo "Error: oci-cli not found in PATH"; exit 1; }
	@[ -f $(TFVARS) ] || { echo "Error: tfvars file not found at $(TFVARS)"; exit 1; }
	@COMPARTMENT_OCID=$$(grep -E "^compartment_ocid" $(TFVARS) | sed 's/.*"\([^"]*\)".*/\1/' | head -1); \
	REGION=$$(grep -E "^region" $(TFVARS) | sed 's/.*"\([^"]*\)".*/\1/' | head -1); \
	if [ -z "$$COMPARTMENT_OCID" ] || [ -z "$$REGION" ]; then \
		echo "Error: Could not extract compartment_ocid or region from $(TFVARS)"; \
		exit 1; \
	fi; \
	echo "Fetching available images for region: $$REGION"; \
	echo "=== aarch64 (ARM) images — for VM.Standard.A1.Flex ==="; \
	$(OCI) compute image list --compartment-id "$$COMPARTMENT_OCID" --region "$$REGION" \
	  --query 'data[?("operating-system"==`Canonical Ubuntu` || "operating-system"==`Oracle Linux`) && contains("display-name",`aarch64`)].{id:id, os:"operating-system", version:"operating-system-version", name:"display-name"}' \
	  --all --profile $(OCI_PROFILE); \
	echo ""; \
	echo "=== x86_64 (AMD) images — for VM.Standard.E2.1.Micro ==="; \
	$(OCI) compute image list --compartment-id "$$COMPARTMENT_OCID" --region "$$REGION" \
	  --query 'data[?("operating-system"==`Canonical Ubuntu` || "operating-system"==`Oracle Linux`) && !contains("display-name",`aarch64`)].{id:id, os:"operating-system", version:"operating-system-version", name:"display-name"}' \
	  --all --profile $(OCI_PROFILE)

.PHONY: get-regions
# List subscribed OCI regionsmake
get-regions:
	@command -v $(OCI) >/dev/null 2>&1 || { echo "Error: oci-cli not found in PATH"; exit 1; }
	@$(OCI) iam region-subscription list --profile $(OCI_PROFILE) --query 'data[].{"region-name":"region-name", status:status}'
