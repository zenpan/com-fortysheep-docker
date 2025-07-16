# modules/networking/variables.tf
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to be used for resource names"
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

variable "availability_zone" {
  description = "Availability zone"
  type        = string
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "nat_instance_id" {
  description = "ID of the NAT instance"
  type        = string
}

variable "nat_network_interface_id" {
  description = "The ID of the NAT instance's primary network interface"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
}
