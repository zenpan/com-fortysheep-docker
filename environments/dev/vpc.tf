data "aws_ami" "al2_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-arm64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

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

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 0)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-public-subnet"
      Description = "Public subnet for ${var.project_name}"
      Type        = "Public"
      Purpose     = "Host public-facing resources like load balancers"
      CreatedBy   = "Terraform"
    }
  )
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 1)
  availability_zone = var.availability_zone

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-private-subnet"
      Description = "Private subnet for ${var.project_name}"
      Type        = "Private"
      Purpose     = "Host Docker containers and other private resources"
      CreatedBy   = "Terraform"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-igw"
      Description = "Internet Gateway for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}

# Security Group for NAT Instance
resource "aws_security_group" "nat" {
  name        = "${local.name_prefix}-nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-nat-sg"
      Description = "Security group for NAT instance"
      CreatedBy   = "Terraform"
    }
  )
}

# NAT Instance
resource "aws_instance" "nat" {
  ami           = data.aws_ami.al2_arm.id
  instance_type = "t4g.nano"
  key_name      = var.key_name
  subnet_id     = aws_subnet.public.id

  associate_public_ip_address = true
  source_dest_check           = false
  vpc_security_group_ids      = [aws_security_group.nat.id]

  user_data = <<-EOF
              #!/bin/bash
              sysctl -w net.ipv4.ip_forward=1
              /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
              EOF

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-nat-instance"
      Description = "NAT Instance for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-public-rt"
      Description = "Public route table for ${var.project_name}"
      Type        = "Public"
      CreatedBy   = "Terraform"
    }
  )
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.nat.primary_network_interface_id
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-private-rt"
      Description = "Private route table for ${var.project_name}"
      Type        = "Private"
      CreatedBy   = "Terraform"
    }
  )
}

# Route Table Association for Public Subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Route Table Association for Private Subnet
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}