#!/usr/bin/env python3
"""
Author : Kevin Ritchey <kevin@fortysheep.com>
Date   : 2025-01-07
Purpose: Create initial Terraform project structure
Warning: You only need to run this script if you are
         a maintainer of this project and need to recreate the structure.
"""

import datetime
import os
import pathlib
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get environment variables with defaults
COMPANY_NAME = os.getenv('COMPANY_NAME', 'Company')
AUTHOR_NAME = os.getenv('AUTHOR_NAME', 'Author')
AUTHOR_EMAIL = os.getenv('AUTHOR_EMAIL', 'author@example.com')
PROJECT_NAME = os.getenv('PROJECT_NAME', 'Infrastructure')
TERRAFORM_VERSION = os.getenv('TERRAFORM_VERSION', '1.7.0')
AWS_PROVIDER_VERSION = os.getenv('AWS_PROVIDER_VERSION', '5.31')
STATE_BUCKET_NAME = os.getenv('STATE_BUCKET_NAME', 'terraform-state')
DYNAMODB_TABLE_NAME = os.getenv('DYNAMODB_TABLE_NAME', 'terraform-locks')

# Get script directory
SCRIPT_DIR = pathlib.Path(__file__).parent.absolute()

def create_versions_tf(env_path):
    """Create versions.tf with current version constraints"""
    versions_content = f"""terraform {{
  required_version = ">= {TERRAFORM_VERSION}"
  required_providers {{
    aws = {{
      source  = "hashicorp/aws"
      version = "~> {AWS_PROVIDER_VERSION}"
    }}
  }}
}}
"""
    with open(env_path / 'versions.tf', 'w') as f:
        f.write(versions_content)

def create_directory_structure():
    """Create the basic directory structure, skipping existing files"""
    # Create environment directories
    for env in ['prod', 'dev', 'staging']:
        path = SCRIPT_DIR / 'environments' / env
        path.mkdir(parents=True, exist_ok=True)
        # Create environment files
        for file in ['main.tf', 'variables.tf', 'outputs.tf', 'backend.tf']:
            file_path = path / file
            if not file_path.exists():
                file_path.touch()
        # Create versions.tf only if it doesn't exist
        versions_path = path / 'versions.tf'
        if not versions_path.exists():
            create_versions_tf(path)

    # Create module directories
    for module in ['vpc', 'ecs', 'rds', 'security', 'iam']:
        path = SCRIPT_DIR / 'modules' / module
        path.mkdir(parents=True, exist_ok=True)
        # Create module files
        for file in ['main.tf', 'variables.tf', 'outputs.tf', 'README.md']:
            file_path = path / file
            if not file_path.exists():
                file_path.touch()

def create_gitignore():
    """Create .gitignore file"""
    gitignore_content = """# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude sensitive files containing credentials
*.tfvars
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include tfvars files that are safe to share
!example.tfvars

# CLI configuration files
.terraformrc
terraform.rc

# macOS system files
.DS_Store

# Editor specific files
.vscode/
.idea/

# Environment variables
.env
"""
    with open(SCRIPT_DIR / '.gitignore', 'w') as f:
        f.write(gitignore_content)

def create_readme():
    """Create README.md with template variables and detailed setup instructions"""
    readme_content = f"""# {COMPANY_NAME} {PROJECT_NAME}

This repository contains the Terraform configurations for the {COMPANY_NAME} {PROJECT_NAME}.

## Initial Directory Structure Setup

1. Ensure Python 3.6+ is installed:
   ```bash
   python3 --version
   ```
2. Install the required Python package:
    ```bash
    pip install python-dotenv
    # or
    pip3 install python-dotenv
    # or if you need user-level installation
    pip install --user python-dotenv
    ```
3. Create a .env file in the root directory with your specific values:
    ```
    COMPANY_NAME=YourCompany
    AUTHOR_NAME=Your Name
    AUTHOR_EMAIL=your.email@example.com
    PROJECT_NAME=Your Project Name
    TERRAFORM_VERSION=1.7.0
    AWS_PROVIDER_VERSION=5.31
    STATE_BUCKET_NAME=your-terraform-state-bucket
    DYNAMODB_TABLE_NAME=your-terraform-locks-table
    ```
4. Make the setup script executable:
    ```bash
    chmod +x setup.py
    ```
5. Run the setup script to create the project structure:
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
- Terraform >= {TERRAFORM_VERSION}
- AWS Provider ~> {AWS_PROVIDER_VERSION}
- AWS CLI configured with appropriate credentials

## State Management

State is stored in S3 bucket: {STATE_BUCKET_NAME}
State locking is managed through DynamoDB table: {DYNAMODB_TABLE_NAME}

## Environment Configuration
The .env file is used for local configuration and is not committed to the repository for security reasons. Make sure to:

1. Copy the example values above to a new .env file
1. Modify the values to match your environment
1. Never commit the .env file (it's included in .gitignore)

## Maintainer

{AUTHOR_NAME} ({AUTHOR_EMAIL})

## License

MIT License

Copyright (c) {datetime.datetime.now().year} {AUTHOR_NAME}

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
"""
    with open(SCRIPT_DIR / 'README.md', 'w') as f:
        f.write(readme_content)

def main():
    """Main function to set up the project structure"""
    try:
        # Check if any files/directories would be affected
        existing_files = []
        for env in ['prod', 'dev', 'staging']:
            env_path = SCRIPT_DIR / 'environments' / env
            if env_path.exists():
                existing_files.append(f"environments/{env}")
                for file in env_path.glob('*'):
                    existing_files.append(f"  {file.relative_to(SCRIPT_DIR)}")

        for module in ['vpc', 'ecs', 'rds', 'security', 'iam']:
            module_path = SCRIPT_DIR / 'modules' / module
            if module_path.exists():
                existing_files.append(f"modules/{module}")
                for file in module_path.glob('*'):
                    existing_files.append(f"  {file.relative_to(SCRIPT_DIR)}")

        if existing_files:
            print("The following existing files/directories will be preserved:")
            for file in existing_files:
                print(file)
            response = input("\nContinue? Only .gitignore and README.md will be overwritten. [y/N]: ")
            if response.lower() != 'y':
                print("Setup cancelled.")
                return 0

        create_directory_structure()
        create_gitignore()  # Will overwrite
        create_readme()     # Will overwrite
        print(f"\nProject structure created/updated successfully in {SCRIPT_DIR}")
        print("Note: .gitignore and README.md were overwritten if they existed.")
    except Exception as e:
        print(f"Error creating project structure: {e}")
        return 1
    return 0

if __name__ == "__main__":
    exit(main())
