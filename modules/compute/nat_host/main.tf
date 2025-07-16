resource "aws_security_group" "nat" {
  name        = "${var.name_prefix}-nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all traffic from VPC"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "Allow SSH from my IP address"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ec2_connect_cidrs
    description = "Allow EC2 Instance Connect"
  }

  # Allow HTTPS for package updates and NAT routing
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS for package updates and NAT routing"
  }

  # Allow HTTP for package updates and NAT routing
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP for package updates and NAT routing"
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

  # Allow all traffic from private subnets for NAT functionality
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.10.0/24", "10.0.11.0/24"]
    description = "Allow NAT routing for private subnets"
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-nat-sg"
      Description = "Security group for NAT instance"
      CreatedBy   = "Terraform"
    }
  )
}

resource "aws_instance" "nat" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_id
  iam_instance_profile        = var.ssm_role_name
  associate_public_ip_address = true
  source_dest_check           = false
  vpc_security_group_ids      = [aws_security_group.nat.id]

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint               = "enabled"
  }

  user_data = templatefile(
    "${path.module}/scripts/user_data.tpl",
    {}
  )

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
    encrypted   = true
    kms_key_id  = var.kms_key_id
  }

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-nat-instance"
      Description = "NAT Instance for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}
