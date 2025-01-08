# Security Group for NAT Instance
resource "aws_security_group" "nat" {
  name        = "${local.name_prefix}-nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main.id

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
    cidr_blocks = [local.myip]
    description = "Allow SSH from my IP address"
  }

  # Allow EC2 Instance Connect
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = data.aws_ip_ranges.ec2_instance_connect.cidr_blocks
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
    local.common_tags,
    {
      Name        = "${local.name_prefix}-nat-sg"
      Description = "Security group for NAT instance"
      CreatedBy   = "Terraform"
    }
  )
}

# NAT Instance
resource "aws_instance" "nat" {
  # ami           = data.aws_ami.al2_arm.id
  ami                         = data.aws_ami.al2023_arm.id
  instance_type               = var.nat_instance_type
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public.id
  iam_instance_profile        = data.aws_iam_role.existing_ssm_role.name
  associate_public_ip_address = true
  source_dest_check           = false
  vpc_security_group_ids      = [aws_security_group.nat.id]
  
  # Ensure Instance Metadata Service is v1 is not enabled
  metadata_options {
    http_tokens = "required"
    http_put_response_hop_limit = 1
    http_endpoint = "enabled"
  }

  user_data = templatefile("${path.module}/scripts/nat_instance_user_data.sh")

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = merge(
    local.common_tags,
    {
      Name        = "${local.name_prefix}-nat-instance"
      Description = "NAT Instance for ${var.project_name}"
      CreatedBy   = "Terraform"
    }
  )
}