#!/usr/bin/env python3
import os
from dotenv import load_dotenv
from pathlib import Path


# -----------------------------------------------------------------------------
def create_backend():
    """
    Create the backend.tf file for the dev environment
    """
    
    # Load environment variables
    load_dotenv()
    
    # Create backend content
    backend_content = f"""terraform {{
  backend "s3" {{
    bucket         = "{os.getenv('STATE_BUCKET_NAME')}"
    key            = "dev/terraform.tfstate"
    region         = "{os.getenv('AWS_REGION')}"
    dynamodb_table = "{os.getenv('DYNAMODB_TABLE_NAME')}"
    encrypt        = true
  }}
}}
"""
    
    # Ensure the directory exists
    backend_path = Path('environments/dev/backend.tf')
    backend_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Write to backend.tf
    with open(backend_path, 'w') as f:
        f.write(backend_content)


# -----------------------------------------------------------------------------
def create_tfvars():
    """
    Create the terraform.tfvars file for the dev environment
    """
    
    # Load environment variables
    load_dotenv()
    
    # Create tfvars content
    tfvars_content = f"""aws_region   = "{os.getenv('AWS_REGION')}"
project_name = "{os.getenv('PROJECT_NAME')}"
environment  = "{os.getenv('ENVIRONMENT')}"
company_name = "{os.getenv('COMPANY_NAME')}"
vpc_cidr     = "{os.getenv('VPC_CIDR')}"
owner        = "{os.getenv('OWNER')}"
team         = "{os.getenv('TEAM')}"
"""
    
    # Ensure the directory exists
    tfvars_path = Path('environments/dev/terraform.tfvars')
    tfvars_path.parent.mkdir(parents=True, exist_ok=True)
    
    # Write to terraform.tfvars
    with open(tfvars_path, 'w') as f:
        f.write(tfvars_content)

if __name__ == "__main__":
    create_backend()
    create_tfvars()
