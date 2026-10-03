output "alb_dns_name" {
  description = "Public DNS name for Metabase through the Application Load Balancer."
  value       = aws_lb.metabase.dns_name
}

output "metabase_url" {
  description = "Metabase public URL."
  value       = "http://${aws_lb.metabase.dns_name}"
}

output "ec2_public_ip" {
  description = "Public IPv4 address for SSH access to the Metabase EC2 instance."
  value       = aws_instance.metabase.public_ip
}

output "ssh_command" {
  description = "SSH command using the project dedicated key."
  value       = "ssh -i ~/.ssh/lab-metabase-key ec2-user@${aws_instance.metabase.public_ip}"
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = aws_db_instance.metabase.address
}
