# modules/compute/database_host/variables.tf

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "nat_security_group_id" {
  description = "Security group ID of the NAT instance"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the database instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the database instance"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ssm_role_name" {
  description = "Name of the IAM role for SSM"
  type        = string
}

variable "data_volume_size" {
  description = "Size of the data volume in GB"
  type        = number
  default     = 50
}

variable "kms_key_id" {
  description = "KMS key ID for EBS encryption"
  type        = string
}
