# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-vpc"
      Description = "VPC for ${var.project_name}"
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
    var.common_tags,
    {
      Name        = "${var.name_prefix}-default-sg"
      Description = "Default security group - denies all traffic"
      CreatedBy   = "Terraform"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-igw"
      Description = "Internet Gateway for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}