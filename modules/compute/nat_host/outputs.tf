output "instance_id" {
  description = "ID of the NAT instance"
  value       = aws_instance.nat.id
}

output "public_ip" {
  description = "Public IP address of the NAT instance"
  value       = aws_instance.nat.public_ip
}

output "instance_arn" {
  value = aws_instance.nat.arn
}

output "security_group_id" {
  value = aws_security_group.nat.id
}

output "primary_network_interface_id" {
  description = "ID of the primary network interface of the NAT instance"
  value       = aws_instance.nat.primary_network_interface_id
}
