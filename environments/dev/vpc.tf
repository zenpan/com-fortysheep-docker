# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-vpc"
      Description = "VPC for ${var.project_name} ${var.environment} environment"
      Purpose     = "Host Docker infrastructure and related services"
      CreatedBy   = "Terraform"
    }
  )
}

# Manage the default security group to restrict all traffic
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # No ingress rules - denies all inbound traffic
  
  # No egress rules - denies all outbound traffic

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-default-sg"
      Description = "Default security group - denies all traffic"
      CreatedBy   = "Terraform"
    }
  )
}