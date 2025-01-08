output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "nat_instance_id" {
  description = "ID of the NAT instance"
  value       = aws_instance.nat.id
}

# Add other outputs as needed
output "nat_instance_public_ip" {
  description = "Public IP address of the NAT instance"
  value       = aws_instance.nat.public_ip
}

output "database_private_ip" {
  description = "Private IP address of the database instance"
  value       = aws_instance.database.private_ip
}

# Output the public IP for reference
output "docker_host_public_ip" {
  description = "Public IP address of the Docker host"
  value       = aws_eip.docker.public_ip
}

# Optional: Output the EIP allocation ID
output "docker_host_eip_id" {
  description = "Allocation ID of the Docker host Elastic IP"
  value       = aws_eip.docker.id
}