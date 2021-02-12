output "s3_bucket_domain_name" {
  value = module.create_s3_backup.s3_bucket_domain_name
}
#output "cloudfront_dns" {
# value        = var.enable_acm_cloudfront ? module.create_cloudfront.*.cloudfront_dns[0] : null
#  description = "The DNS name of the ttrpgtools server"
#}
#output "public_ip" {
#  value       = module.create_ec2.public_ip
#  description = "The public IP of the ttrpgtools server"
#}
output "aws_lb_dns_name" {
  value       = module.create_network.aws_lb_dns_name
  description = "DNS name for load balancer"
}
