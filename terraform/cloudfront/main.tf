provider "aws" {
  region  = "us-east-1"
  profile = "ttrpg"
}

resource "aws_cloudfront_distribution" "ttrpg_distribution" {
  origin {
    domain_name = var.aws_lb_dns_name
    origin_id   = var.aws_lb_id

    custom_origin_config {
      origin_read_timeout      = 30
      origin_keepalive_timeout = 30
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""

  logging_config {
    include_cookies = false
    bucket          = "ttrpg-terraform-bucket.s3.amazonaws.com"
    prefix          = "logs_"
  }

  aliases = [var.domain_name,"${var.dr_hostname}.${var.domain_name}","${var.ii_hostname}.${var.domain_name}","${var.pa_hostname}.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.aws_lb_id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
      headers = [
        "*",
      ]

    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Name = "ttrpgtools-cloudfront"
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    cloudfront_default_certificate = false
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = [format("%s.%s", var.dr_hostname,var.domain_name),format("%s.%s", var.ii_hostname,var.domain_name),format("%s.%s", var.pa_hostname,var.domain_name)]
  tags = {
    Name = "ttrpg-tools-ssl"
  }

}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  zone_id         = var.aws_dns_zone_id
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "www" {
  zone_id = var.aws_dns_zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "60"

  records = [aws_cloudfront_distribution.ttrpg_distribution.domain_name]
}

resource "aws_route53_record" "dungeon-revealer" {
  zone_id = var.aws_dns_zone_id
  name    = var.dr_hostname
  type    = "CNAME"
  ttl     = "60"

  records = [aws_cloudfront_distribution.ttrpg_distribution.domain_name]
}

resource "aws_route53_record" "improved-initiative" {
  zone_id = var.aws_dns_zone_id
  name    = var.ii_hostname
  type    = "CNAME"
  ttl     = "60"

  records = [aws_cloudfront_distribution.ttrpg_distribution.domain_name]
}

resource "aws_route53_record" "paragon" {
  zone_id = var.aws_dns_zone_id
  name    = var.pa_hostname
  type    = "CNAME"
  ttl     = "60"

  records = [aws_cloudfront_distribution.ttrpg_distribution.domain_name]
}
