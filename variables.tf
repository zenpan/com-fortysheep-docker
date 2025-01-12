# General/Common Variables
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod"
  }
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid VPC CIDR block"
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  validation {
    condition     = alltrue([for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All public subnet CIDR blocks must be valid"
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
  validation {
    condition     = alltrue([for cidr in var.private_subnet_cidrs : can(cidrhost(cidr, 0))])
    error_message = "All private subnet CIDR blocks must be valid"
  }
}

# Instance Variables
variable "nat_instance_type" {
  description = "Instance type for NAT instance"
  type        = string
  default     = "t4g.small"
  validation {
    condition     = can(regex("^t4g\\.", var.nat_instance_type))
    error_message = "NAT instance must be a t4g instance type for ARM architecture"
  }
}

variable "key_name" {
  description = "Name of SSH key pair for instances"
  type        = string
}

variable "database_instance_type" {
  description = "Instance type for the database server"
  type        = string
  default     = "t3.medium"
}

variable "database_volume_size" {
  description = "Size of the database data volume in GB"
  type        = number
  default     = 50
}

variable "docker_instance_type" {
  description = "Instance type for Docker host"
  type        = string
  default     = "t3.medium"
}

variable "company_name" {
  description = "Name of the company"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "us-west-2a"
}

variable "team" {
  description = "Team responsible for the resources"
  type        = string
}