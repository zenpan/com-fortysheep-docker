# KMS key for EBS encryption
resource "aws_kms_key" "ebs_encryption" {
  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    var.common_tags,
    {
      Name      = "${var.name_prefix}-ebs-encryption-key"
      Purpose   = "EBS Volume Encryption"
      CreatedBy = "Terraform"
    }
  )
}

resource "aws_kms_alias" "ebs_encryption" {
  name          = "alias/${var.name_prefix}-ebs-encryption"
  target_key_id = aws_kms_key.ebs_encryption.key_id
}

# KMS key policy
resource "aws_kms_key_policy" "ebs_encryption" {
  key_id = aws_kms_key.ebs_encryption.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EBS service to use the key"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}
