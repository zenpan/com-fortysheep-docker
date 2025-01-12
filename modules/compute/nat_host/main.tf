# modules/compute/nat_host/main.tf

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
      Name        = "${var.name_prefix}-nat-sg"
      Description = "Security group for NAT instance"
      CreatedBy   = "Terraform"
    }
  )
}

resource "aws_instance" "nat" {
  ami                         = var.ami_id
  instance_type              = var.instance_type
  key_name                   = var.key_name
  subnet_id                  = var.public_subnet_id
  iam_instance_profile       = var.ssm_role_name
  associate_public_ip_address = true
  source_dest_check          = false
  vpc_security_group_ids     = [aws_security_group.nat.id]

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    http_endpoint              = "enabled"
  }

  user_data = templatefile(
    "${path.module}/scripts/user_data.tpl",
    {}
  )

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
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
