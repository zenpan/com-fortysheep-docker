locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # For the NAT instance security group
  # myip = "${chomp(data.http.myip.body)}/32"
  myip = "${chomp(data.http.myip.response_body)}/32" # Changed from body to response_body

  # Common tags if not defined in variables
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      ManagedBy   = "Terraform"
    }
  )
}

# Data source to get your current IP
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Data source for EC2 Instance Connect IPs
data "aws_ip_ranges" "ec2_instance_connect" {
  regions  = [var.aws_region]
  services = ["ec2_instance_connect"]
}

# Data source for the AL2023 ARM AMI
data "aws_ami" "al2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source for the SSM role
data "aws_iam_role" "existing_ssm_role" {
  name = "AmazonSSMRoleForInstancesQuickSetup" # or your SSM role name
}
