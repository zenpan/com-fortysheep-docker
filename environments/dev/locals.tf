locals {
  name_prefix = "${var.company_name}-${var.project_name}-${var.environment}"
  myip        = "${chomp(data.http.myip.response_body)}/32"
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    Team        = var.team
    ManagedBy   = "Terraform"
  }
}