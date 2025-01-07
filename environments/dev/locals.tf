locals {
  name_prefix = "${var.company_name}-${var.project_name}-${var.environment}"
  
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Team        = var.team
    ManagedBy   = "Terraform"
  }
}