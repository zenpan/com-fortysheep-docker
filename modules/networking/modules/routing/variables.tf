variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "nat_instance_id" {
  description = "ID of the NAT instance"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
}

variable "nat_network_interface_id" {
  description = "The ID of the NAT instance's primary network interface"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}