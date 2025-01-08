variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "availability_zone" {
  description = "AWS availability zone"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
}

variable "company_name" {
  description = "Company name for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

variable "team" {
  description = "Team responsible for the resources"
  type        = string
}

variable "docker_instance_type" {
  description = "Instance type for the Docker host"
  type        = string
  default     = "t4g.medium"
}

variable "nat_instance_type" {
  description = "Instance type for the NAT instance"
  type        = string
  default     = "t4g.nano"
}

variable "database_instance_type" {
  description = "Instance type for the database host"
  type        = string
  default     = "t4g.medium"
}