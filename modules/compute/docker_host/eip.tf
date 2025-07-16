# Allocate Elastic IP for Docker host
resource "aws_eip" "docker" {
  domain = "vpc"

  tags = merge(
    var.common_tags, # Changed from local.common_tags to var.common_tags
    {
      Name        = "${var.name_prefix}-docker-host-eip" # Changed from local.name_prefix to var.name_prefix
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
