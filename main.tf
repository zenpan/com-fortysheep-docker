module "security" {
  source = "./modules/security"

  name_prefix  = local.name_prefix
  common_tags  = local.common_tags
  project_name = var.project_name
}

module "networking" {
  source = "./modules/networking"

  vpc_cidr                 = var.vpc_cidr
  name_prefix              = local.name_prefix
  common_tags              = local.common_tags
  project_name             = var.project_name
  availability_zone        = var.availability_zone
  public_subnets           = var.public_subnet_cidrs
  private_subnets          = var.private_subnet_cidrs
  nat_instance_id          = module.nat_host.instance_id
  nat_network_interface_id = module.nat_host.primary_network_interface_id
  kms_key_id               = module.security.cloudwatch_logs_kms_key_arn

  depends_on = [module.security]
}
