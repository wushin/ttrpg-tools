terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  validation_method         = var.use_dns_method ? "DNS" : "EMAIL"
  subject_alternative_names = [format("%s.%s", var.dr_hostname,var.domain_name),format("%s.%s", var.ii_hostname,var.domain_name),format("%s.%s", var.pa_hostname,var.domain_name)]
  tags = {
    Name = "ttrpg-tools-ssl"
  }
}

resource "aws_acm_certificate_validation" "cert" {
  count                   = var.use_dns_method ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "cert_validation" {
  count           = var.use_dns_method ? 4 : 0
  name            = aws_acm_certificate.cert.domain_validation_options.*.resource_record_name[count.index]
  records         = [aws_acm_certificate.cert.domain_validation_options.*.resource_record_value[count.index]]
  type            = aws_acm_certificate.cert.domain_validation_options.*.resource_record_type[count.index]
  zone_id         = var.aws_dns_zone_id
  allow_overwrite = true
  ttl             = 60
}

resource "aws_acm_certificate_validation" "ttrpg-tools-ssl" {
  count           = var.use_dns_method ? 0 : 1
  certificate_arn = aws_acm_certificate.cert.arn
}
