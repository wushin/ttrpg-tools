output "aws_lb_dns_name" {
  value       = aws_lb.web.dns_name
  description = "DNS name for load balancer"
}
output "aws_lb_id" {
  value       = aws_lb.web.id
  description = "AWS ID for load balancer"
}
output "aws_lb_target_id" {
  value       = aws_lb_target_group.ttrpgtools.arn
  description = "AWS ID for load balancer"
}
output "aws_sg_alb_id" {
  value       = aws_security_group.alb.id
  description = "Secuirity Group for instances"
}
output "aws_sg_alb_arn" {
  value       = aws_security_group.alb.arn
  description = "Secuirity Group ARN for instances"
}
output "aws_sg_ec2_id" {
  value       = aws_security_group.instance.id
  description = "Secuirity Group for instances"
}
output "aws_sg_ec2_arn" {
  value       = aws_security_group.instance.arn
  description = "Secuirity Group ARN for instances"
}
output "aws_vpc_default_id" {
  value       = aws_vpc.default.id
  description = "Default VPC"
}
output "aws_subnet_one_id" {
  value       = aws_subnet.default_one.id
  description = "Subnet IDs"
}
output "aws_subnet_one_arn" {
  value       = aws_subnet.default_one.arn
  description = "Subnet IDs"
}
output "aws_subnet_two_id" {
  value       = aws_subnet.default_two.id
  description = "Subnet IDs"
}
output "aws_subnet_two_arn" {
  value       = aws_subnet.default_two.arn
  description = "Subnet IDs"
}
output "aws_subnet_three_id" {
  value       = aws_subnet.default_three.id
  description = "Subnet IDs"
}
output "aws_subnet_three_arn" {
  value       = aws_subnet.default_three.arn
  description = "Subnet IDs"
}
output "aws_subnet_four_id" {
  value       = aws_subnet.default_four.id
  description = "Subnet IDs"
}
output "aws_subnet_four_arn" {
  value       = aws_subnet.default_four.arn
  description = "Subnet IDs"
}
