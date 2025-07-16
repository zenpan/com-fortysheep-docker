# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 0)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-public-subnet"
      Description = "Public subnet for ${var.project_name}"
      Type        = "Public"
      Purpose     = "Host public-facing resources like load balancers"
      CreatedBy   = "Terraform"
    }
  )
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, 1)
  availability_zone = var.availability_zone

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-private-subnet"
      Description = "Private subnet for ${var.project_name}"
      Type        = "Private"
      Purpose     = "Host Docker containers and other private resources"
      CreatedBy   = "Terraform"
    }
  )
}
