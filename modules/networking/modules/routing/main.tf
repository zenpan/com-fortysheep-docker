# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.internet_gateway_id
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-public-rt"
      Description = "Public route table for ${var.project_name}"
      Type        = "Public"
      CreatedBy   = "Terraform"
    }
  )
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = var.nat_network_interface_id
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-private-rt"
      Description = "Private route table for ${var.project_name}"
      Type        = "Private"
      CreatedBy   = "Terraform"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id
}
