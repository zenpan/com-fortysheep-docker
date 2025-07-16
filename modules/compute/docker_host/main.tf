# Security group for the docker host
resource "aws_security_group" "docker" {
  name        = "docker-host"
  description = "Security group for docker host"
  vpc_id      = var.vpc_id

  # Allow ICMP from anywhere
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ICMP from anywhere"
  }

  # Allow SSH from my IP address
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
    description = "Allow SSH from my IP address"
  }

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  # Allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  # Allow HTTPS for package updates and Docker registry
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS for package updates and Docker registry"
  }

  # Allow HTTP for package updates and Docker registry
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP for package updates and Docker registry"
  }

  # Allow DNS resolution
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow DNS resolution"
  }

  # Allow internal VPC communication
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow internal VPC communication"
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-docker-host-sg"
      Description = "Docker Security Group for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}

# Docker host EC2 instance
resource "aws_instance" "docker" {
  ami           = var.ami_id
  instance_type = var.docker_instance_type

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.docker.id]
  associate_public_ip_address = true

  # Use the same key pair as NAT instance
  key_name = var.key_name

  # Use the same SSM role for management
  iam_instance_profile = var.iam_instance_profile

  # Ensure IMDSv2 is enabled
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  user_data = templatefile(
    "${path.module}/scripts/user_data.tpl",
    {}
  )

  # Config root volume to 20GB
  root_block_device {
    volume_size = 20
    encrypted   = true
    kms_key_id  = var.kms_key_id

    # tags for the root volume
    tags = merge(
      var.common_tags,
      {
        Name        = "${var.name_prefix}-docker-host-root"
        Description = "Root volume for Docker Host"
        CreatedBy   = "Terraform"
      }
    )
  }

  # Add data volume of 20GB
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = 20
    volume_type = "gp2"
    encrypted   = true
    kms_key_id  = var.kms_key_id

    # tags for the EBS volume
    tags = merge(
      var.common_tags,
      {
        Name        = "${var.name_prefix}-docker-host-data"
        Description = "Data volume for Docker Host"
        CreatedBy   = "Terraform"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-docker-host"
      Description = "Docker Host for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}
