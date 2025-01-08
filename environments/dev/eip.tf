# Allocate Elastic IP for Docker host
resource "aws_eip" "docker" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-docker-host-eip"
      Description = "Elastic IP for Docker Host"
      CreatedBy   = "Terraform"
    }
  )
}

# Associate Elastic IP with Docker host
resource "aws_eip_association" "docker" {
  instance_id   = aws_instance.docker.id
  allocation_id = aws_eip.docker.id
}