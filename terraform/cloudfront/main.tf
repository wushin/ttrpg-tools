terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
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

  aliases = [data.aws_ssm_parameter.domain.value,"${data.aws_ssm_parameter.dr_host.value}.${data.aws_ssm_parameter.domain.value}","${data.aws_ssm_parameter.ii_host.value}.${data.aws_ssm_parameter.domain.value}","${data.aws_ssm_parameter.pa_host.value}.${data.aws_ssm_parameter.domain.value}"]

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
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = false
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
  }
}

resource "aws_route53_record" "www" {
  count = var.enable_aws_dns ? 1 : 0
  zone_id = var.aws_dns_zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "60"

  records = [aws_cloudfront_distribution.ttrpg_distribution.domain_name]
}

resource "aws_route53_record" "dungeon-revealer" {
  count = var.enable_aws_dns ? 1 : 0
  zone_id = var.aws_dns_zone_id
  name    = data.aws_ssm_parameter.dr_host.value
  type    = "CNAME"
  ttl     = "60"

  records = [aws_cloudfront_distribution.ttrpg_distribution.domain_name]
}

resource "aws_route53_record" "improved-initiative" {
  count = var.enable_aws_dns ? 1 : 0
  zone_id = var.aws_dns_zone_id
  name    = data.aws_ssm_parameter.ii_host.value
  type    = "CNAME"
  ttl     = "60"

  records = [aws_cloudfront_distribution.ttrpg_distribution.domain_name]
}

resource "aws_route53_record" "paragon" {
  count = var.enable_aws_dns ? 1 : 0
  zone_id = var.aws_dns_zone_id
  name    = data.aws_ssm_parameter.pa_host.value
  type    = "CNAME"
  ttl     = "60"

  records = [aws_cloudfront_distribution.ttrpg_distribution.domain_name]
}
