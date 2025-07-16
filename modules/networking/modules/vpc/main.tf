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

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.name_prefix}"
  retention_in_days = 365 # 1 year retention for compliance
  kms_key_id        = var.kms_key_id
  skip_destroy      = true # Prevent issues with log group recreation

  lifecycle {
    prevent_destroy = false
    ignore_changes  = []
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-vpc-flow-logs"
      Description = "CloudWatch log group for VPC Flow Logs"
      CreatedBy   = "Terraform"
    }
  )
}

# IAM role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-vpc-flow-logs-role"
      Description = "IAM role for VPC Flow Logs"
      CreatedBy   = "Terraform"
    }
  )
}

# IAM policy for VPC Flow Logs
resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.name_prefix}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          aws_cloudwatch_log_group.vpc_flow_logs.arn,
          "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
        ]
      }
    ]
  })
}

# VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-vpc-flow-logs"
      Description = "VPC Flow Logs for network monitoring"
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
