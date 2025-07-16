# Security group for the database host
resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-database-host"
  description = "Security group for database host"
  vpc_id      = var.vpc_id

  # Allow ICMP from NAT instance
  ingress {
    from_port       = 8
    to_port         = 0
    protocol        = "icmp"
    security_groups = [var.nat_security_group_id]
    description     = "Allow ICMP from NAT instance"
  }

  # Allow SSH from NAT instance
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.nat_security_group_id]
    description     = "Allow SSH from NAT instance"
  }

  # Allow PostgreSQL from NAT instance
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.nat_security_group_id]
    description     = "Allow PostgreSQL from NAT instance"
  }

  # Allow MySQL from NAT instance
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.nat_security_group_id]
    description     = "Allow MySQL from NAT instance"
  }

  # Allow HTTPS for package updates and software downloads
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS for package updates"
  }

  # Allow HTTP for package updates (some repos still use HTTP)
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP for package updates"
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
      Name        = "${var.name_prefix}-db-host-sg"
      Description = "DB Security Group for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}

# Database EC2 instance
resource "aws_instance" "database" {
  ami           = var.ami_id
  instance_type = var.instance_type

  subnet_id                   = var.private_subnet_id
  vpc_security_group_ids      = [aws_security_group.database.id]
  associate_public_ip_address = false

  # disable Instance Metadata Service version 1
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  # Use the same key pair as NAT instance
  key_name = var.key_name

  # Use the same SSM role for management
  iam_instance_profile = var.ssm_role_name

  # User data script
  user_data = templatefile(
    "${path.module}/scripts/user_data.tpl",
    {}
  )

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = var.kms_key_id
  }

  # Add data volume
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = var.data_volume_size
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = var.kms_key_id

    tags = merge(
      var.common_tags,
      {
        Name = "${var.name_prefix}-database-data"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-db-instance"
      Description = "DB Instance for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}
