output "bastion" {
  value       = aws_route53_record.bastion.fqdn
  description = "The public IP of the ttrpgtools server"
}
