provider "aws" {
  alias   = "ttrpg-root"
  region  = var.aws_region
  profile = "ttrpg-root"
}

module "lets_encrypt_cert" {
  providers = {
    aws = aws.ttrpg-root
  }

  source  = "./terraform-aws-lets-encrypt/"
  name    = "lets-encrypt-ttrpg"
  domains = [
    var.domain_name,
    "*.${var.domain_name}",
  ]

  email_address  = var.domain_email
  hosted_zone_id = var.aws_dns_zone_id
  staging        = false
}

resource "aws_cloudwatch_event_rule" "cronjob" {
  provider            = aws.ttrpg-root
  name                = "ttrpg-ssl-cron"
  schedule_expression = "cron(0 0 1 * ? *)"
}

resource "aws_cloudwatch_event_target" "cronjob-target" {
  provider  = aws.ttrpg-root
  target_id = "lets-encrypt-ttrpg"
  rule      = aws_cloudwatch_event_rule.cronjob.name
  arn       = module.lets_encrypt_cert.lambda_function_arn
}

resource "aws_lambda_permission" "allow_events" {
  provider      = aws.ttrpg-root
  statement_id  = "AWSEvents_ttrpg-ssl-cron"
  action        = "lambda:InvokeFunction"
  function_name = module.lets_encrypt_cert.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cronjob.arn
}
