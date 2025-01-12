# modules/compute/nat_host/variables.tf

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "my_ip" {
  description = "Your IP address for SSH access"
  type        = string
}

variable "ec2_connect_cidrs" {
  description = "CIDR blocks for EC2 Instance Connect"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "ami_id" {
  description = "AMI ID for the NAT instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the NAT instance"
  type        = string
  default     = "t4g.small"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet"
  type        = string
}

variable "ssm_role_name" {
  description = "Name of the IAM role for SSM"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}
