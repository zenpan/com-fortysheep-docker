data "aws_ami" "al2023_arm" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ip_ranges" "ec2_instance_connect" {
  regions  = [var.aws_region]
  services = ["ec2_instance_connect"]
}

data "aws_iam_role" "existing_ssm_role" {
  name = "AmazonSSMRoleForInstancesQuickSetup"
}

data "aws_iam_policy_document" "ec2_instance_connect" {
  statement {
    effect = "Allow"
    actions = [
      "ec2-instance-connect:SendSSHPublicKey"
    ]
    resources = [
      aws_instance.nat.arn
    ]
  }
}

# Get the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

