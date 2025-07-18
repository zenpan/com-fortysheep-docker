locals {
  # Create AWS-compliant name prefix (alphanumeric, hyphens, underscores only)
  name_prefix = "${replace(lower(var.project_name), " ", "-")}-${var.environment}"

  # For the NAT instance security group
  myip = "${chomp(data.http.myip.response_body)}/32"

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

# Note: NAT instance now uses Ubuntu 24.04 AMI (same as other instances)
# Amazon Linux AMI data source removed since all instances use Ubuntu

# Data source for the SSM role
data "aws_iam_role" "existing_ssm_role" {
  name = "AmazonSSMRoleForInstancesQuickSetup" # or your SSM role name
}
