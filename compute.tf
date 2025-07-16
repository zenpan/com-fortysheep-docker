module "nat_host" {
  source = "./modules/compute/nat_host"

  vpc_id            = module.networking.vpc_id
  vpc_cidr          = var.vpc_cidr
  name_prefix       = local.name_prefix
  my_ip             = local.myip
  ec2_connect_cidrs = data.aws_ip_ranges.ec2_instance_connect.cidr_blocks
  common_tags       = local.common_tags
  ami_id            = data.aws_ami.al2023_arm.id
  instance_type     = var.nat_instance_type
  key_name          = var.key_name
  public_subnet_id  = module.networking.public_subnet_ids[0]
  ssm_role_name     = data.aws_iam_role.existing_ssm_role.name
  project_name      = var.project_name
  kms_key_id        = module.security.ebs_kms_key_id
}

module "database_host" {
  source = "./modules/compute/database_host"

  vpc_id                = module.networking.vpc_id
  vpc_cidr              = var.vpc_cidr
  name_prefix           = local.name_prefix
  nat_security_group_id = module.nat_host.security_group_id
  common_tags           = local.common_tags
  project_name          = var.project_name
  ami_id                = data.aws_ami.ubuntu.id
  instance_type         = var.database_instance_type
  private_subnet_id     = module.networking.private_subnet_ids[0]
  key_name              = var.key_name
  ssm_role_name         = data.aws_iam_role.existing_ssm_role.name
  data_volume_size      = var.database_volume_size
  kms_key_id            = module.security.ebs_kms_key_id
}

module "docker_host" {
  source = "./modules/compute/docker_host"

  vpc_id               = module.networking.vpc_id
  vpc_cidr             = var.vpc_cidr
  allowed_ip           = local.myip
  ami_id               = data.aws_ami.ubuntu.id
  subnet_id            = module.networking.public_subnet_ids[0]
  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
  key_name             = var.key_name
  project_name         = var.project_name
  iam_instance_profile = data.aws_iam_role.existing_ssm_role.name
  docker_instance_type = var.docker_instance_type
  kms_key_id           = module.security.ebs_kms_key_id
}
