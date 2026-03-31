.PHONY: all
all: help

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

 
TFVARS ?= private/terraform.tfvars
 
OCI_PROFILE ?= DEFAULT

.PHONY: help
# Show available targets and their descriptions
help:
	@awk '/^# /{desc=substr($$0,3)} /^[a-zA-Z_-]+:/{if(desc){printf "  %-22s %s\n",$$1,desc; desc=""}}' $(MAKEFILE_LIST)

.PHONY: update-providers
# Upgrade Terraform providers to latest compatible versions
update-providers:
	terraform init -upgrade

.PHONY: plan-vm
# Preview infrastructure changes without applying them
plan-vm:
	terraform init
	terraform plan -var-file=$(TFVARS)

.PHONY: create-vm
# Create or update the VM and all associated resources
create-vm:
	terraform init
	terraform apply -var-file=$(TFVARS) -auto-approve

.PHONY: destroy-vm
# Tear down all Terraform-managed infrastructure
destroy-vm:
	terraform init
	terraform destroy -var-file=$(TFVARS) -auto-approve

.PHONY: public-ip
# Print the SSH command to connect to the VM
public-ip:
	@echo "ssh opc@$$(terraform output -raw public_ip)"

.PHONY: ssh-vm
# SSH into the VM
ssh-vm:
	ssh ubuntu@$$(terraform output -raw public_ip)

.PHONY: validate-oci-login
# Verify that OCI CLI is installed and credentials are valid
validate-oci-login:
	@command -v oci >/dev/null 2>&1 || { echo "Error: oci-cli not found in PATH"; exit 1; }
	@echo "Validating OCI CLI credentials with profile: $(OCI_PROFILE)"
	oci iam user get --user-id $$(oci iam user list --profile $(OCI_PROFILE) --query 'data[0].id' --raw-output --profile $(OCI_PROFILE)) --profile $(OCI_PROFILE) >/dev/null 2>&1 && echo "✓ OCI CLI login successful" || { echo "✗ OCI CLI login failed"; exit 1; }

.PHONY: print-account-tfvars
# Extract OCI account details and print them as tfvars
print-account-tfvars:
	@command -v oci >/dev/null 2>&1 || { echo "Error: oci-cli not found in PATH"; exit 1; }
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
	TENANCY_OCID="$$(oci iam availability-domain list --profile $(OCI_PROFILE) --all --query 'data[0]."compartment-id"' --raw-output 2>/dev/null || true)"; \
	USER_OCID="$$(read_cfg_value user)"; \
	FINGERPRINT="$$(read_cfg_value fingerprint)"; \
	PRIVATE_KEY_PATH="$$(read_cfg_value key_file)"; \
	REGION="$$(read_cfg_value region)"; \
	COMPARTMENT_OCID="$$(oci iam compartment list --profile $(OCI_PROFILE) --compartment-id "$$TENANCY_OCID" --access-level ACCESSIBLE --all --query 'data[?"lifecycle-state"==`ACTIVE` && name!=`ManagedCompartmentForPaaS`] | [0].id' --raw-output 2>/dev/null || true)"; \
	if [ -z "$$COMPARTMENT_OCID" ] || [ "$$COMPARTMENT_OCID" = "null" ]; then COMPARTMENT_OCID="$$TENANCY_OCID"; fi; \
	printf 'tenancy_ocid     = "%s"\n' "$$(clean_or_placeholder "$$TENANCY_OCID")"; \
	printf 'user_ocid        = "%s"\n' "$$(clean_or_placeholder "$$USER_OCID")"; \
	printf 'fingerprint      = "%s"\n' "$$(clean_or_placeholder "$$FINGERPRINT")"; \
	printf 'private_key_path = "%s"\n' "$$(clean_or_placeholder "$$PRIVATE_KEY_PATH")"; \
	printf 'region           = "%s"\n' "$$(clean_or_placeholder "$$REGION")"; \
	printf 'compartment_ocid = "%s"\n' "$$(clean_or_placeholder "$$COMPARTMENT_OCID")"

.PHONY: get-image-ocid
# List the last Ubuntu images, then the last Oracle Linux images
get-image-ocid:
	@command -v oci >/dev/null 2>&1 || { echo "Error: oci-cli not found in PATH"; exit 1; }
	@COMPARTMENT_OCID=$$(grep -E "^compartment_ocid" $(TFVARS) | sed 's/.*"\([^"]*\)".*/\1/' | head -1); \
	REGION=$$(grep -E "^region" $(TFVARS) | sed 's/.*"\([^"]*\)".*/\1/' | head -1); \
	if [ -z "$$COMPARTMENT_OCID" ] || [ -z "$$REGION" ]; then \
		echo "Error: Could not extract compartment_ocid or region from $(TFVARS)"; \
		exit 1; \
	fi; \
	echo "Fetching available images for region: $$REGION"; \
	echo "Canonical Ubuntu (last 10):"; \
	oci compute image list --compartment-id "$$COMPARTMENT_OCID" --region "$$REGION" --query 'sort_by(data[?"operating-system"==`Canonical Ubuntu`], &"time-created")[-10:].{id:id, os:"operating-system", version:"operating-system-version", "display-name": "display-name", "time-created": "time-created"}' --all --profile $(OCI_PROFILE); \
	echo "Oracle Linux (last 10):"; \
	oci compute image list --compartment-id "$$COMPARTMENT_OCID" --region "$$REGION" --query 'sort_by(data[?"operating-system"==`Oracle Linux`], &"time-created")[-10:].{id:id, os:"operating-system", version:"operating-system-version", "display-name": "display-name", "time-created": "time-created"}' --all --profile $(OCI_PROFILE)

.PHONY: list-compatible-images
# List images compatible with instance_shape (Canonical Ubuntu first, then Oracle Linux)
list-compatible-images:
	@command -v oci >/dev/null 2>&1 || { echo "Error: oci-cli not found in PATH"; exit 1; }
	@IMAGE_COUNT=$${IMAGE_COUNT:-10}; \
	COMPARTMENT_OCID=$$(grep -E "^compartment_ocid" $(TFVARS) | sed 's/.*"\([^\"]*\)".*/\1/' | head -1); \
	REGION=$$(grep -E "^region" $(TFVARS) | sed 's/.*"\([^\"]*\)".*/\1/' | head -1); \
	SHAPE=$$(grep -E "^instance_shape" $(TFVARS) | sed 's/.*"\([^\"]*\)".*/\1/' | head -1); \
	if [ -z "$$COMPARTMENT_OCID" ] || [ -z "$$REGION" ] || [ -z "$$SHAPE" ]; then \
		echo "Error: Could not extract compartment_ocid, region, or instance_shape from $(TFVARS)"; \
		exit 1; \
	fi; \
	echo "Fetching images compatible with shape: $$SHAPE (region: $$REGION)"; \
	echo "Canonical Ubuntu (latest $$IMAGE_COUNT):"; \
	oci compute image list --compartment-id "$$COMPARTMENT_OCID" --region "$$REGION" --shape "$$SHAPE" \
	  --operating-system "Canonical Ubuntu" \
	  --sort-by TIMECREATED --sort-order DESC --limit $$IMAGE_COUNT \
	  --query 'data[].{id:id,"display-name":"display-name",os:"operating-system",version:"operating-system-version"}' \
	  --profile $(OCI_PROFILE); \
	echo "Oracle Linux (latest $$IMAGE_COUNT):"; \
	oci compute image list --compartment-id "$$COMPARTMENT_OCID" --region "$$REGION" --shape "$$SHAPE" \
	  --operating-system "Oracle Linux" \
	  --sort-by TIMECREATED --sort-order DESC --limit $$IMAGE_COUNT \
	  --query 'data[].{id:id,"display-name":"display-name",os:"operating-system",version:"operating-system-version"}' \
	  --profile $(OCI_PROFILE)

.PHONY: list-shapes
# List available compute shapes in the region (use to find x86 shapes; ARM shapes often start with 'VM.Standard.A1')
list-shapes:
    @command -v oci >/dev/null 2>&1 || { echo "Error: oci-cli not found in PATH"; exit 1; }
	@COMPARTMENT_OCID=$$(grep -E "^compartment_ocid" $(TFVARS) | sed 's/.*"\([^\"]*\)".*/\1/' | head -1); \
	REGION=$$(grep -E "^region" $(TFVARS) | sed 's/.*"\([^\"]*\)".*/\1/' | head -1); \
	if [ -z "$$COMPARTMENT_OCID" ] || [ -z "$$REGION" ]; then \
		echo "Error: Could not extract compartment_ocid or region from $(TFVARS)"; \
		exit 1; \
	fi; \
	echo "Fetching available shapes for region: $$REGION"; \
	oci compute shape list --compartment-id "$$COMPARTMENT_OCID" --region "$$REGION" --all --profile $(OCI_PROFILE) | head -200
