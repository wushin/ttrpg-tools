provider "aws" {
  alias   = "ttrpg"
  region  = var.aws_region
  profile = "ttrpg"
}

provider "aws" {
  alias   = "ttrpg-1"
  region  = "us-east-1"
  profile = "ttrpg"
}

module "create_s3_backup" {
  source = "./backup"
  providers = {
    aws = aws.ttrpg
  }
  aws_region = var.aws_region
}

module "create_ec2_alb_vpc" {
  source = "./server"
  providers = {
    aws = aws.ttrpg
  }
  aws_region               = var.aws_region
  instance_type            = var.instance_type
  sshpath                  = var.sshpath
  private_key_name         = var.private_key_name
  public_key_name          = var.public_key_name
  git_user                 = var.git_user
  aws_s3_access_key_id     = var.aws_s3_access_key_id
  aws_s3_secret_access_key = var.aws_s3_secret_access_key
}

module "create_certifcate" {
  count = var.enable_acm_cloudfront ? 1 : 0
  source = "./certificate"
  providers = {
    aws = aws.ttrpg-1
  }
  domain_name     = var.domain_name
  use_dns_method  = var.use_dns_method
  aws_dns_zone_id = var.aws_dns_zone_id
  dr_hostname     = var.dr_hostname
  ii_hostname     = var.ii_hostname
  pa_hostname     = var.pa_hostname
}

module "create_cloudfront" {
  count = var.enable_acm_cloudfront ? 1 : 0
  source = "./cloudfront"
  providers = {
    aws = aws.ttrpg
  }
  aws_region            = var.aws_region
  domain_name           = var.domain_name
  aws_dns_zone_id       = var.aws_dns_zone_id
  enable_aws_dns        = var.enable_aws_dns
  aws_lb_dns_name       = module.create_ec2_alb_vpc.aws_lb_dns_name
  aws_lb_id             = module.create_ec2_alb_vpc.aws_lb_id
  acm_certificate_arn   = module.create_certifcate.*.acm_certificate_arn[count.index]
  dr_hostname           = var.dr_hostname
  ii_hostname           = var.ii_hostname
  pa_hostname           = var.pa_hostname
}
