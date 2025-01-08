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
