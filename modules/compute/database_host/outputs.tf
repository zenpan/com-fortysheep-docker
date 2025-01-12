output "private_ip" {
  description = "Private IP address of the database instance"
  value       = aws_instance.database.private_ip
}

output "instance_id" {
  description = "ID of the database instance"
  value       = aws_instance.database.id
}

output "security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}
