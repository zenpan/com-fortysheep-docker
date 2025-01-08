# Security group for the docker host
resource "aws_security_group" "docker" {
  name        = "docker-host"
  description = "Security group for docker host"
  vpc_id      = aws_vpc.main.id

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
    cidr_blocks = [local.myip]
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

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-docker-host-sg"
      Description = "Docker Security Group for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}

# Docker host EC2 instance
resource "aws_instance" "docker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.docker_instance_type

  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.docker.id]
  associate_public_ip_address = true

  # Use the same key pair as NAT instance
  key_name = var.key_name

  # Use the same SSM role for management
  iam_instance_profile = data.aws_iam_role.existing_ssm_role.name

  # Ensure IMDSv2 is enabled
    metadata_options {
        http_tokens = "required"
        http_put_response_hop_limit = 1
        http_endpoint = "enabled"
    }

  user_data = templatefile("${path.module}/scripts/docker_host_user_data.sh")

  # Config root volume to 20GB
  root_block_device {
    volume_size = 20

    # tags for the root volume
    tags = merge(
      local.common_tags,
      {
        Name        = "${local.name_prefix}-docker-host-root"
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

    # tags for the EBS volume
    tags = merge(
      local.common_tags,
      {
        Name        = "${local.name_prefix}-docker-host-data"
        Description = "Data volume for Docker Host"
        CreatedBy   = "Terraform"
      }
    )
  }  

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-docker-host"
      Description = "Docker Host for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}