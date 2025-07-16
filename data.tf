data "aws_iam_policy_document" "ec2_instance_connect" {
  statement {
    effect = "Allow"
    actions = [
      "ec2-instance-connect:SendSSHPublicKey"
    ]
    resources = [
      module.nat_host.instance_arn
    ]
  }
}

# Get the latest Ubuntu 24.04 LTS AMI for ARM64
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd*/ubuntu-noble-24.04-arm64-server-*"]
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

  filter {
    name   = "state"
    values = ["available"]
  }
}
