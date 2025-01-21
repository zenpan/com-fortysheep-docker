.PHONY: plan apply destroy init fmt validate help
.DEFAULT_GOAL := help
include .env
export

KEY ?= $(SSH_KEY)
NAT_USER ?= ec2-user
UBUNTU_USER ?= ubuntu

apply:  ## Apply terraform changes
	terraform apply -auto-approve

check-security:  ## Check security of the code
	gitleaks detect --source . --verbose
	git secrets --scan || true
	checkov --quiet -d .
	tfsec --config-file=.tfsec.yaml --tfvars-file=terraform.tfvars .
	trufflehog filesystem . --force-skip-binaries --force-skip-archives --log-level=-1

connect-docker:  ## Connect to Docker host
	@terraform init > /dev/null 2>&1
	@terraform state pull > /dev/null && \
	DOCKER_IP=$$(terraform output -raw docker_host_public_ip); \
	echo "Connecting to docker host..."; \
	ssh -o StrictHostKeyChecking=no $(UBUNTU_USER)@$$DOCKER_IP -i $(KEY) 

connect-db:  ## Connect to database host via NAT instance
	@terraform init > /dev/null 2>&1
	@terraform state pull > /dev/null && \
	NAT_IP=$$(terraform output -raw nat_host_public_ip) && \
	DB_IP=$$(terraform output -raw database_private_ip); \
	echo "Connecting to database host via NAT instance..."; \
	ssh -o StrictHostKeyChecking=no \
		-o ProxyCommand="ssh -W %h:%p -i $(KEY) $(NAT_USER)@$$NAT_IP" \
		-i $(KEY) $(UBUNTU_USER)@$$DB_IP

connect-nat:  ## Connect to NAT instance
	@terraform init > /dev/null 2>&1
	@terraform state pull > /dev/null && \
	IP=$$(terraform output -raw nat_host_public_ip); \
	echo "Connecting to $$IP..."; \
	ssh -o StrictHostKeyChecking=no $(NAT_USER)@$$IP -i $(KEY)

destroy:  ## Destroy terraform resources
	terraform destroy -auto-approve

fmt:  ## Format terraform files
	terraform fmt -recursive

help:  ## Show this help.
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init:  ## Initialize terraform
	terraform init

inventory:  ## (Re)Create Ansible inventory file
	@python3 create-inventory.py

ip:  ## Show the IP address of NAT host
	terraform output nat_host_public_ip

# If you want to get just the value without the formatting:
ip-raw:  ## Show the IP address of NAT host (raw)
	terraform output -raw nat_host_public_ip

outputs:  ## Show terraform outputs
	terraform output

plan:  ## Show terraform plan
	terraform plan

update-hosts:  ## Update OS and reboot if necessary
	@ansible-playbook -i inventory.yml playbooks/update-hosts.yml

validate:  ## Validate terraform configuration
	terraform validate
