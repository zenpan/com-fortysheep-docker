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
}

# module "nat_host" {
#   source = "./modules/compute/nat_host"

#   vpc_id            = module.networking.vpc_id
#   vpc_cidr          = var.vpc_cidr
#   name_prefix       = local.name_prefix
#   my_ip             = local.myip
#   ec2_connect_cidrs = data.aws_ip_ranges.ec2_instance_connect.cidr_blocks
#   common_tags       = local.common_tags
#   ami_id            = data.aws_ami.al2023_arm.id
#   instance_type     = var.nat_instance_type
#   key_name          = var.key_name
#   public_subnet_id  = module.networking.public_subnet_ids[0]
#   ssm_role_name     = data.aws_iam_role.existing_ssm_role.name
#   project_name      = var.project_name
# }

# module "database_host" {
#   source = "./modules/compute/database_host"

#   vpc_id                = module.networking.vpc_id
#   name_prefix           = local.name_prefix
#   nat_security_group_id = module.nat_host.security_group_id
#   common_tags           = local.common_tags
#   project_name          = var.project_name
#   ami_id                = data.aws_ami.ubuntu.id
#   instance_type         = var.database_instance_type
#   private_subnet_id     = module.networking.private_subnet_ids[0]
#   key_name              = var.key_name
#   ssm_role_name         = data.aws_iam_role.existing_ssm_role.name
#   data_volume_size      = var.database_volume_size
# }
