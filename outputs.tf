output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "nat_host_id" {
  description = "ID of the NAT host"
  value       = module.nat_host.instance_id
}

output "nat_host_public_ip" {
  description = "Public IP address of the NAT host"
  value       = module.nat_host.public_ip
}

output "database_private_ip" {
  description = "Private IP address of the database instance"
  value       = module.database_host.private_ip
}

output "docker_host_public_ip" {
  description = "Public IP address of the Docker host"
  value       = module.docker_host.public_ip
}

output "docker_host_eip_id" {
  description = "Allocation ID of the Docker host Elastic IP"
  value       = module.docker_host.eip_id
}
