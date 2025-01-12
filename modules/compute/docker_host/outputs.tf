output "public_ip" {
  description = "Public IP address of the Docker host"
  value       = aws_eip.docker.public_ip
}

output "eip_id" {
  description = "Allocation ID of the Docker host Elastic IP"
  value       = aws_eip.docker.id
}
