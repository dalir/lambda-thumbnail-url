# Makefile for Terraform
TERRAFORM_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

clean: build-clean package-clean terraform-clean

# Clean up old plans, fetch the latest remote state, create a new plan, and detach the remote state
plan: terraform-get terraform-clean terraform-remote-state-up terraform-plan

# Clean up old plans, fetch the latest remote state, create a new plan, and detach the remote state
import: terraform-get terraform-clean terraform-remote-state-up terraform-import

# Clean up old plans, fetch the latest remote state, create a new plan, and detach the remote state
graph: terraform-get terraform-clean terraform-remote-state-up terraform-graph terraform-remote-state-down

# Pull the latest remote state, apply the changes, and detach the remote state
apply: terraform-get terraform-remote-state-up terraform-up terraform-remote-state-down

# Pull the latest remote state, remove the AWS resources, and detach the remote state
destroy: terraform-get terraform-remote-state-up terraform-down terraform-remote-state-down

# Creates a plan with the changes to the environment
terraform-plan:
	@echo "You are creating a terraform plan. Review it and then run ${WARN_COLOR}make apply${NO_COLOR}."
	cd ${TERRAFORM_DIR} && \
	TF_VAR_git_sha=${git_sha} \
	terraform plan -input=true -refresh=true -out .terraform/$(account_id)-${environment}-${git_sha}.tfplan \
	-var-file=./environment/${environment}.tfvars \
	-var "environment=${environment}" \
	-var "publish=${publish}" \
	-var "git_sha=${git_sha}" \
	-var "function_name=${lambda_function}" \
	-var "repo_organization=${repo_organization}" \
	-var "repo_name=${repo_name}" \
	-var "repo_full_name=${repo_full_name}" \
	-var "provider_role=${role_arn}" \
	-var "account_id=${account_id}" \
	-var "provider_bucket=${bucket}"

terraform-import:
	@echo "You are creating a terraform plan. Review it and then run ${WARN_COLOR}make apply${NO_COLOR}."
	cd ${TERRAFORM_DIR} && \
	TF_VAR_git_sha=${git_sha} \
	terraform import \
	-var-file=./environment/${environment}.tfvars \
	-var "environment=${environment}" \
	-var "publish=${publish}" \
	-var "git_sha=${git_sha}" \
	-var "function_name=${lambda_function}" \
	-var "repo_organization=${repo_organization}" \
	-var "repo_name=${repo_name}" \
	-var "repo_full_name=${repo_full_name}" \
	-var "provider_role=${role_arn}" \
	-var "account_id=${account_id}" \
	-var "provider_bucket=${bucket}" \
	aws_kms_alias.thumbslack alias/thumbslack




# Creates a plan with the changes to the environment
terraform-graph:
	@echo "You are creating a terraform plan. Review it and then run ${WARN_COLOR}make apply${NO_COLOR}."
	cd ${TERRAFORM_DIR} && \
	TF_VAR_git_sha=${git_sha} \
	terraform graph \
	-draw-cycles \
	-type=plan | dot -Tpng > graph.png

# Connects the remote state for the environment. Note: If terraform-down is not run, there will be problems if using different environment.
terraform-up:
	@echo "You are ${WARN_COLOR}APPLYING${NO_COLOR} the ${WARN_COLOR}${environment}${NO_COLOR} environment."
	cd ${TERRAFORM_DIR} && \
	TF_VAR_git_sha=${git_sha} \
	terraform apply \
	.terraform/${account_id}-${environment}-${git_sha}.tfplan

# Disconnects the remote state for the environment.
terraform-down:
	@echo "You are ${WARN_COLOR}DESTROYING${NO_COLOR} the ${WARN_COLOR}${environment}${NO_COLOR} environment."
	cd ${TERRAFORM_DIR} && \
	TF_VAR_git_sha=${git_sha} \
	terraform destroy \
	-auto-approve \
	-var "environment=${environment}" \
	-var "publish=${publish}" \
	-var "git_sha=${git_sha}" \
	-var "function_name=${lambda_function}" \
	-var "repo_organization=${repo_organization}" \
	-var "repo_name=${repo_name}" \
	-var "repo_full_name=${repo_full_name}" \
	-var "provider_role=${role_arn}" \
	-var "account_id=${account_id}" \
	-var "provider_bucket=${bucket}"

terraform-remote-state-up:
	cd ${TERRAFORM_DIR} && terraform init \
	-backend=true \
	-backend-config="acl=bucket-owner-full-control" \
	-backend-config="role_arn=${role_arn}" \
	-backend-config="bucket=${bucket}" \
	-backend-config="key=${environment}/${repo_organization}/${repo_name}/${environment}.terraform.tfstate" \
	-backend-config="region=${region}"

terraform-remote-state-down:
	cd ${TERRAFORM_DIR} && rm -rf .terraform/

terraform-get:
	cd ${TERRAFORM_DIR} && \
	terraform get --update

terraform-clean:
	cd ${TERRAFORM_DIR} && \
	ls | grep .tfplan | xargs -n 1 -t rm -rf

remove-terra-watchdog: terraform-remote-state-up
	- cd ${TERRAFORM_DIR} && \
	terraform state rm aws_cloudwatch_event_rule.end-of-setup-sfn


.PHONY: provision package clean update
