#!/usr/bin/env python3
import os
from dotenv import load_dotenv
from pathlib import Path

def create_tfvars():
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
    create_tfvars()