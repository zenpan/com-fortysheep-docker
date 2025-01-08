.PHONY: plan apply destroy init fmt validate help
include ../../.env
export

KEY ?= $(SSH_KEY)
NAT_USER ?= ec2-user
UBUNTU_USER ?= ubuntu

apply:
	terraform apply -auto-approve

check-security:
	gitleaks detect --source . --verbose
	git secrets --scan
	checkov --quiet -d .
	tfsec --config-file=.tfsec.yaml --tfvars-file=terraform.tfvars .
	trufflehog filesystem . --force-skip-binaries --force-skip-archives --log-level=-1

connect-db:
	@terraform init > /dev/null 2>&1
	@terraform state pull > /dev/null && \
	NAT_IP=$$(terraform output -raw nat_instance_public_ip) && \
	DB_IP=$$(terraform output -raw database_private_ip); \
	echo "Connecting to database host via NAT instance..."; \
	ssh -o StrictHostKeyChecking=no \
		-o ProxyCommand="ssh -W %h:%p -i $(KEY) $(NAT_USER)@$$NAT_IP" \
		-i $(KEY) $(UBUNTU_USER)@$$DB_IP

connect-nat:
	@terraform init > /dev/null 2>&1
	@terraform state pull > /dev/null && \
	IP=$$(terraform output -raw nat_instance_public_ip); \
	echo "Connecting to $$IP..."; \
	ssh -o StrictHostKeyChecking=no $(NAT_USER)@$$IP -i $(KEY)

destroy:
	terraform destroy -auto-approve

fmt:
	terraform fmt

help:
	@echo "Available commands:"
	@echo "  make plan     - Show terraform plan"
	@echo "  make apply    - Apply terraform changes"
	@echo "  make destroy  - Destroy terraform resources"
	@echo "  make init     - Initialize terraform"
	@echo "  make fmt      - Format terraform files"
	@echo "  make validate - Validate terraform configuration"
	@echo "  make outputs  - Show outputs"
	@echo "  make ip       - Show the IP address of NAT instance"
	@echo "  make ip-raw   - Show raw IP address"
	@echo "  make connect  - Connect to EC2 instance"

init:
	terraform init
ip:
	terraform output nat_instance_public_ip

# If you want to get just the value without the formatting:
ip-raw:
	terraform output -raw nat_instance_public_ip

outputs:
	terraform output

plan:
	terraform plan

validate:
	terraform validate
