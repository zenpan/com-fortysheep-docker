module "vpc" {
  source = "./modules/vpc"

  vpc_cidr     = var.vpc_cidr
  name_prefix  = var.name_prefix
  common_tags  = var.common_tags
  project_name = var.project_name
}

module "subnets" {
  source = "./modules/subnets"

  vpc_id               = module.vpc.vpc_id
  vpc_cidr             = module.vpc.vpc_cidr
  availability_zone    = var.availability_zone
  public_subnet_cidrs  = var.public_subnets
  private_subnet_cidrs = var.private_subnets
  name_prefix          = var.name_prefix
  common_tags          = var.common_tags
  project_name         = var.project_name
}

module "routing" {
  source = "./modules/routing"

  vpc_id                   = module.vpc.vpc_id
  nat_instance_id          = var.nat_instance_id
  nat_network_interface_id = var.nat_network_interface_id
  public_subnet_ids        = module.subnets.public_subnet_ids
  private_subnet_ids       = module.subnets.private_subnet_ids
  name_prefix              = var.name_prefix
  common_tags              = var.common_tags
  internet_gateway_id      = module.vpc.internet_gateway_id
  project_name             = var.project_name
}