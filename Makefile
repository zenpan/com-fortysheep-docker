.PHONY: plan apply destroy init fmt validate help
.DEFAULT_GOAL := help
include .env
export

KEY ?= $(SSH_KEY)
NAT_USER ?= ubuntu
UBUNTU_USER ?= ubuntu

apply:  ## Apply terraform changes
	@terraform apply -auto-approve || { \
		echo "❌ Terraform apply failed. Checking for CloudWatch log group conflicts..."; \
		if aws logs describe-log-groups --log-group-name-prefix "/aws/vpc/flowlogs/docker-infrastructure-dev" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q "docker-infrastructure-dev"; then \
			echo "🔧 Importing existing CloudWatch log group..."; \
			terraform import 'module.networking.module.vpc.aws_cloudwatch_log_group.vpc_flow_logs' '/aws/vpc/flowlogs/docker-infrastructure-dev'; \
			echo "♻️ Retrying terraform apply..."; \
			terraform apply -auto-approve; \
		else \
			echo "❌ Apply failed for other reasons. Please check the output above."; \
			exit 1; \
		fi; \
	}

check-security:  ## Comprehensive security scanning
	@echo "🔍 Running security scans..."
	@echo "📝 Scanning for secrets with gitleaks..."
	gitleaks detect --source . --verbose --max-target-megabytes 10
	@echo "🔧 Scanning Terraform configuration with trivy..."
	trivy config --config trivy.yaml --severity CRITICAL,HIGH --format table --tf-vars terraform.tfvars . --quiet || echo "⚠️ Trivy config scan failed, continuing..."
	@echo "🗂️ Scanning filesystem for vulnerabilities with trivy..."
	trivy fs --config trivy.yaml --scanners vuln,secret,misconfig --format table . --offline-scan --quiet || echo "⚠️ Trivy fs scan failed, continuing..."
	@echo "☑️ Scanning IaC configuration with checkov..."
	checkov --quiet -d . || echo "⚠️ Checkov scan failed, continuing..."
	@echo "⚡ Running static analysis with semgrep..."
	semgrep --config=auto --severity=ERROR --quiet . 2>/dev/null || echo "⚠️ Semgrep scan failed, continuing..."
	@echo "✅ Security scanning completed!"

connect-docker: inventory  ## Connect to Docker host
	@terraform init > /dev/null 2>&1
	@terraform state pull > /dev/null && \
	DOCKER_IP=$$(terraform output -raw docker_host_public_ip); \
	echo "Connecting to docker host..."; \
	ssh -o StrictHostKeyChecking=no $(UBUNTU_USER)@$$DOCKER_IP -i $(KEY)

connect-db: inventory  ## Connect to database host via NAT instance
	@terraform init > /dev/null 2>&1
	@terraform state pull > /dev/null && \
	NAT_IP=$$(terraform output -raw nat_host_public_ip) && \
	DB_IP=$$(terraform output -raw database_private_ip); \
	echo "Connecting to database host via NAT instance..."; \
	ssh -o StrictHostKeyChecking=no \
		-o ProxyCommand="ssh -W %h:%p -i $(KEY) $(NAT_USER)@$$NAT_IP" \
		-i $(KEY) $(UBUNTU_USER)@$$DB_IP

connect-nat: inventory  ## Connect to NAT instance
	@terraform init > /dev/null 2>&1
	@terraform state pull > /dev/null && \
	IP=$$(terraform output -raw nat_host_public_ip); \
	echo "Connecting to $$IP..."; \
	ssh -o StrictHostKeyChecking=no $(NAT_USER)@$$IP -i $(KEY)

destroy:  ## Destroy terraform resources
	terraform destroy -auto-approve

fmt:  ## Format terraform files
	terraform fmt -recursive

help:  ## Show this help
	@echo "Available commands:"
	@echo ""
	@echo "🏗️  \033[1mTerraform Infrastructure:\033[0m"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {if ($$1 ~ /^(apply|destroy|fmt|init|plan|validate)$$/) printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
	@echo ""
	@echo "🔐 \033[1mSecurity & Quality:\033[0m"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {if ($$1 ~ /^(check-security|pre-commit-install|pre-commit-run)$$/) printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
	@echo ""
	@echo "🎭 \033[1mAnsible Operations:\033[0m"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {if ($$1 ~ /^(ansible-.*|inventory|update-hosts|setup-database|setup-docker|setup-all)$$/) printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
	@echo ""
	@echo "🔗 \033[1mConnection & Info:\033[0m"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {if ($$1 ~ /^(connect-.*|ip|ip-raw|outputs)$$/) printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
	@echo ""
	@echo "📚 \033[1mDocumentation:\033[0m"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {if ($$1 ~ /^(docs-.*|readme)$$/) printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort
	@echo ""
	@echo "🛠️  \033[1mDevelopment Setup:\033[0m"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {if ($$1 ~ /^(setup-dev)$$/) printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

init:  ## Initialize terraform
	terraform init

inventory:  ## (Re)Create Ansible inventory file
	@source venv/bin/activate && python3 create-inventory.py

ip:  ## Show the IP address of NAT host
	terraform output nat_host_public_ip

# If you want to get just the value without the formatting:
ip-raw:  ## Show the IP address of NAT host (raw)
	terraform output -raw nat_host_public_ip

outputs:  ## Show terraform outputs
	terraform output

plan:  ## Show terraform plan
	terraform plan

pre-commit-install:  ## Install pre-commit hooks
	@echo "🪝 Installing pre-commit hooks..."
	@source venv/bin/activate && pre-commit install

pre-commit-run:  ## Run pre-commit hooks on all files
	@echo "🔍 Running pre-commit hooks..."
	@source venv/bin/activate && pre-commit run --all-files

setup-dev:  ## Setup development environment
	@echo "🚀 Setting up development environment..."
	@./setup-dev.sh

update-hosts: inventory  ## Update OS and reboot if necessary
	@ansible-playbook -i inventory.yml playbooks/update-hosts.yml

setup-database: inventory  ## Setup database instance with MariaDB and PostgreSQL
	@ansible-playbook -i inventory.yml playbooks/setup-database.yml

setup-docker: inventory  ## Setup Docker instance with Docker and Docker Compose
	@ansible-playbook -i inventory.yml playbooks/setup-docker.yml

setup-all: inventory  ## Setup all instances (database and docker)
	@ansible-playbook -i inventory.yml playbooks/setup-database.yml
	@ansible-playbook -i inventory.yml playbooks/setup-docker.yml

ansible-requirements:  ## Install Ansible collections from requirements.yml
	@echo "📦 Installing Ansible collections..."
	@ansible-galaxy collection install -r requirements.yml

validate:  ## Validate terraform configuration
	terraform validate

ansible-lint:  ## Run ansible-lint on playbooks
	@echo "🔍 Running ansible-lint..."
	@source venv/bin/activate && ansible-lint playbooks/

ansible-yaml-lint:  ## Run yamllint on Ansible files
	@echo "🔍 Running yamllint on Ansible files..."
	@source venv/bin/activate && yamllint playbooks/

ansible-syntax-check: inventory  ## Check Ansible playbook syntax
	@echo "🔍 Checking Ansible syntax..."
	@ansible-playbook --syntax-check playbooks/update-hosts.yml
	@ansible-playbook --syntax-check playbooks/setup-database.yml
	@ansible-playbook --syntax-check playbooks/setup-docker.yml

ansible-semgrep:  ## Run Semgrep security analysis on Ansible files
	@echo "🔍 Running Semgrep security analysis..."
	@source venv/bin/activate && semgrep --config=auto --severity=ERROR --severity=WARNING playbooks/

ansible-check-all:  ## Run all Ansible checks
	@echo "🔍 Running all Ansible checks..."
	@make ansible-syntax-check
	@make ansible-yaml-lint
	@make ansible-lint
	@make ansible-semgrep

docs-ansible:  ## View Ansible linting documentation
	@mdcat ANSIBLE-LINTING.md | less

docs-cicd:  ## View CI/CD integration documentation
	@mdcat CICD-INTEGRATION.md | less

docs-security:  ## View security improvements documentation
	@mdcat SECURITY_IMPROVEMENTS.md | less

readme:  ## View project README
	@mdcat README.md | less
