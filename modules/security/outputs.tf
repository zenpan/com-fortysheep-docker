# KMS key outputs
output "ebs_kms_key_id" {
  description = "ID of the KMS key for EBS encryption"
  value       = aws_kms_key.ebs_encryption.key_id
}

output "ebs_kms_key_arn" {
  description = "ARN of the KMS key for EBS encryption"
  value       = aws_kms_key.ebs_encryption.arn
}

output "ebs_kms_alias_name" {
  description = "Name of the KMS key alias for EBS encryption"
  value       = aws_kms_alias.ebs_encryption.name
}
