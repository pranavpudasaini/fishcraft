.SHELLFLAGS = -ec

TF_DIR := $(SCOPE)

ifndef TF_DIR
$(error Please set SCOPE)
endif

.PHONY: clean init format lint validate build

dry: clean init format lint validate build plan
deploy: dry apply
all: deploy

init:
	@echo "Initializing Terraform"
	cd $(TF_DIR); terraform init 
	@echo "Terraform Initialization Complete"

format:
	@echo "Formatting Terraform"
	cd $(TF_DIR); terraform fmt
	@echo "Terraform Formatting Complete"

lint:
	@echo "Linting Terraform"
	cd $(TF_DIR); tflint
	@echo "Terraform Linting Complete"

validate:
	@echo "Validating Terraform"
	cd $(TF_DIR); terraform validate
	@echo "Terraform Validation Complete"

build:
	@echo "Building artifact"
	@mkdir -p dist || true
	cd $(TF_DIR); zip -r ../dist/terraform.zip . -x '.terraform/**' -x '.git/**' -x '.terraform.lock.hcl'
	@echo "Artifact build complete"

plan:
	@echo "Planning Terraform"
	cd $(TF_DIR); terraform plan -out=.tfplan -var-file=.tfvars
	@echo "Terraform Plan Complete"

apply:
	@echo "Applying Terraform"
	cd $(TF_DIR); terraform apply .tfplan
	@echo "Terraform Apply Complete"

destroy:
	@echo "Destroying Terraform"
	cd $(TF_DIR); terraform destroy -var-file=.tfvars
	@echo "Terraform Destroy Complete"

clean:
	@echo "Cleaning build artifacts"
	@rm -rf dist || true
	@echo "Cleaning complete"
