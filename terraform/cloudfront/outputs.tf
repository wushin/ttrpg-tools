output "cloudfront_dns" {
  value       = aws_cloudfront_distribution.ttrpg_distribution.domain_name
  description = "The DNS name of the ttrpgtools server"
}
