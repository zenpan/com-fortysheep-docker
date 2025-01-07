variable "aws_region" {
  description = "AWS region"
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