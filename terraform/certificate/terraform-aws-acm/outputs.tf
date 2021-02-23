output "acm_certificate_arn" {
  value       = aws_acm_certificate.cert.arn
  description = "The ARN of the ttrpgtools server ssl"
}
