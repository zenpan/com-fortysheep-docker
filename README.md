# FortySheep Docker Infrastructure

This repository contains the Terraform configurations for the FortySheep Docker Infrastructure.

## Initial Directory Structure Setup

> **Note:** This section is only relevant for maintainers of this project.
> If you are not a maintainer, you can ignore this section and proceed to the [Structure](#Structure) section.

1. Ensure Python 3.6+ is installed:
   ```bash
   python3 --version
   ```
1. Install the required Python package:
    ```bash
    pip install python-dotenv
    # or
    pip3 install python-dotenv
    # or if you need user-level installation
    pip install --user python-dotenv
    ```
1. Create a .env file in the root directory with your specific values:
    ```
    COMPANY_NAME=YourCompany
    AUTHOR_NAME=Your Name
    AUTHOR_EMAIL=your.email@example.com
    PROJECT_NAME=Your Project Name
    TERRAFORM_VERSION=1.7.0
    AWS_PROVIDER_VERSION=5.31
    STATE_BUCKET_NAME=your-terraform-state-bucket
    DYNAMODB_TABLE_NAME=your-terraform-locks-table
    AWS_REGION=us-east-1
    AWS_AZ=us-east-1a
    ENVIRONMENT=dev
    VPC_CIDR=10.0.0.0/16
    OWNER=your.email@example.com
    TEAM=DevOps
    ```
1. Make the development script executable:
    ```bash
    chmod +x create_dev.py
    ```
1. Run the script to generate development configuration:
    ```bash
    ./create_dev.py
    ```

## Structure

- `modules/`: Reusable Terraform modules
  - `networking/`: VPC, subnets, and routing
  - `compute/`: EC2 instances (NAT, database, Docker hosts)
  - `security/`: Security groups and rules
  - `iam/`: IAM roles and policies
- `playbooks/`: Ansible playbooks for configuration management
- `create-inventory.py`: Generates Ansible inventory from Terraform state
- `Makefile`: Automation commands for infrastructure management

## Prerequisites

- Python 3.6+ with virtual environment support
- Terraform >= 1.7.0
- AWS Provider ~> 5.31
- AWS CLI configured with appropriate credentials
- Security tools: gitleaks, trivy, checkov, semgrep (installed via Homebrew)

## State Management

State is stored in S3 bucket: com-fortysheep-terraform-state
State locking is managed through DynamoDB table: terraform-locks

## Environment Configuration
The .env file is used for local configuration and is not committed to the repository for security reasons. Make sure to:

1. Copy the example values above to a new .env file
1. Modify the values to match your environment
1. Never commit the .env file (it's included in .gitignore)

## Development Environment Setup

After configuring your .env file, follow these steps to set up the development environment:

1. Make the development variables script executable:
    ```bash
    chmod +x create_dev.py
    ```

2. Run the script to generate Terraform configuration:
    ```bash
    ./create_dev.py
    ```

This will create `terraform.tfvars` and `backend.tf` files with your specific configuration values. The generated files are excluded from version control for security reasons.

3. Set up Python virtual environment:
    ```bash
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    ```

4. Initialize and apply the infrastructure:
    ```bash
    make init
    make plan
    make apply
    ```

5. Set up development environment with pre-commit hooks:
    ```bash
    ./setup-dev.sh
    ```

6. Run security scans:
    ```bash
    make check-security
    ```

### Pre-commit Hooks

This project uses pre-commit hooks for automated code quality and security checks:

- **Terraform formatting**: Automatically formats `.tf` files
- **Security scanning**: Runs Trivy and Checkov on Infrastructure as Code
- **Secret detection**: Uses gitleaks to prevent committing secrets
- **Code quality**: Validates YAML/JSON and removes trailing whitespace

**Run manually:**
```bash
make pre-commit-run
```

### CI/CD Security Gates

GitHub Actions workflows provide automated security scanning and validation:

- **Security Scan**: Comprehensive security analysis on every push/PR
- **Terraform Validation**: Infrastructure code validation and planning
- **CI/CD Pipeline**: Combined quality gates and security checks
- **Dependency Updates**: Automated dependency security monitoring

**View security results**: Check the Security tab in GitHub for detailed scan results.

A `terraform.tfvars.example` file is provided in the repository as a template. You can also use this as a reference for the required variables.

## Maintainer

Kevin Ritchey (kevin@fortysheep.com)

## License

MIT License

Copyright (c) 2025 Kevin Ritchey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
