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
  cidr_block             = cidrsubnet(var.vpc_cidr, 4, 0)
  availability_zone      = var.availability_zone
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

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-nat-eip"
      Description = "NAT Gateway EIP for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.main]

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-nat-gw"
      Description = "NAT Gateway for ${var.project_name}"
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
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
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