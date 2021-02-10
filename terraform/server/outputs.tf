output "public_ip" {
  value       = aws_instance.ttrpgserver.public_ip
  description = "The public IP of the ttrpgtools server"
}
output "aws_lb_dns_name" {
  value       = aws_lb.web.dns_name
  description = "DNS name for load balancer"
}
output "aws_lb_id" {
  value       = aws_lb.web.id
  description = "AWS ID for load balancer"
}
