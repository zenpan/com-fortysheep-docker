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
1. Make the setup script executable:
    ```bash
    chmod +x setup.py
    ```
1. Run the setup script to create the project structure:
    ```bash
    ./setup.py
    ```
    
## Structure

- `environments/`: Environment-specific configurations
  - `prod/`: Production environment
  - `staging/`: Staging environment
  - `dev/`: Development environment
- `modules/`: Reusable Terraform modules
  - `vpc/`: VPC and networking
  - `ecs/`: ECS cluster and services
  - `rds/`: Database configurations
  - `security/`: Security groups and rules
  - `iam/`: IAM roles and policies

## Prerequisites

- Python 3.6+
- python-dotenv package
- Terraform >= 1.7.0
- AWS Provider ~> 5.31
- AWS CLI configured with appropriate credentials

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

1. Run the script to generate Terraform variables for the dev environment:
    ```bash
    ./create_dev.py
    ```

This will create a `terraform.tfvars` file in the `environments/dev` directory with your specific configuration values. The generated file is excluded from version control for security reasons.

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
