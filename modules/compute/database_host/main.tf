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

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
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
    http_endpoint              = "enabled"
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
  }

  # Add data volume
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = var.data_volume_size
    volume_type = "gp3"
    encrypted   = true

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
