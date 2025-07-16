variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "name_prefix" {
  description = "Prefix to be used for resource names"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "allowed_ip" {
  description = "IP address allowed to connect to the Docker host"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the Docker host"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the Docker host will be deployed"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for the Docker host"
  type        = string
}

variable "docker_instance_type" {
  description = "EC2 instance type for the Docker host"
  type        = string
  default     = "t4g.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair to associate with the Docker host"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "kms_key_id" {
  description = "KMS key ID for EBS encryption"
  type        = string
}
