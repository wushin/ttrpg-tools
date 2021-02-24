terraform {
  backend "s3" {
    encrypt = true
    bucket = "ttrpg-remote-state-storage-s3"
    dynamodb_table = "ttrpg-state-lock-dynamo"
    region = "us-east-2"
    key = ".terraform/terraform.tfstate"
    profile = "ttrpg"
  }
}

provider "aws" {
  alias   = "ttrpg-root"
  region  = var.aws_region
  profile = "ttrpg-root"
}

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
  aws_region         = var.aws_region
  module_depth       = "../"
  restore_from_local = var.restore_from_local
}

module "create_network" {
  source = "./network"
  providers = {
    aws = aws.ttrpg
  }
  aws_region         = var.aws_region
  module_depth       = "../"
  s3_lb_bucket       = module.create_s3_backup.s3_bucket
}

module "create_ecr" {
  source = "./ecr"
  providers = {
    aws = aws.ttrpg
  }
  aws_region               = var.aws_region
  module_depth             = "../"
}

module "create_ecs" {
  source = "./ecs"
  providers = {
    aws = aws.ttrpg
  }
  aws_region               = var.aws_region
  module_depth             = "../"
  aws_vpc_default_id       = module.create_network.aws_vpc_default_id
  aws_lb_target_id         = module.create_network.aws_lb_target_id
  aws_sg_ec2_id            = module.create_network.aws_sg_ec2_id
  aws_sg_ec2_arn           = module.create_network.aws_sg_ec2_arn
  aws_sg_alb_id            = module.create_network.aws_sg_alb_id
  aws_sg_alb_arn           = module.create_network.aws_sg_alb_arn
  aws_subnet_one_id        = module.create_network.aws_subnet_one_id
  aws_subnet_two_id        = module.create_network.aws_subnet_two_id
  aws_subnet_three_id      = module.create_network.aws_subnet_three_id
  aws_subnet_four_id       = module.create_network.aws_subnet_four_id
  aws_subnet_one_arn       = module.create_network.aws_subnet_one_arn
  aws_subnet_two_arn       = module.create_network.aws_subnet_two_arn
  aws_subnet_three_arn     = module.create_network.aws_subnet_three_arn
  aws_subnet_four_arn      = module.create_network.aws_subnet_four_arn
  nginx_repo_url           = module.create_ecr.nginx_repo_url
  dr_repo_url              = module.create_ecr.dr_repo_url
  ii_repo_url              = module.create_ecr.ii_repo_url
  pa_repo_url              = module.create_ecr.pa_repo_url
  mongo_repo_url           = module.create_ecr.mongo_repo_url
  aws_dns_zone_id          = var.aws_dns_zone_id
  aws_lb_dns_name          = module.create_network.aws_lb_dns_name
  s3_bucket_dr_task        = module.create_s3_backup.s3_bucket_dr_task
}

module "create_codebuild" {
  source = "./codebuild"
  providers = {
    aws = aws.ttrpg-root
  }
  aws_region               = var.aws_region
  module_depth             = "../"
  aws_vpc_default_id       = module.create_network.aws_vpc_default_id
  aws_sg_ec2_id            = module.create_network.aws_sg_ec2_id
  aws_lb_target_id         = module.create_network.aws_lb_target_id
  aws_subnet_one_id        = module.create_network.aws_subnet_one_id
  aws_subnet_four_id       = module.create_network.aws_subnet_four_id
  nginx_repo_url           = module.create_ecr.nginx_repo_url
  dr_repo_url              = module.create_ecr.dr_repo_url
  ii_repo_url              = module.create_ecr.ii_repo_url
  pa_repo_url              = module.create_ecr.pa_repo_url
  aws_sg_alb_id            = module.create_network.aws_sg_alb_id
}

module "create_ec2" {
  depends_on = [
    module.create_s3_backup.aws_s3_bucket,
  ]
  source = "./ec2"
  providers = {
    aws = aws.ttrpg
  }
  aws_region               = var.aws_region
  module_depth             = "../"
  instance_type            = var.instance_type
  sshpath                  = var.sshpath
  private_key_name         = var.private_key_name
  public_key_name          = var.public_key_name
  git_user                 = var.git_user
  aws_s3_access_key_id     = var.aws_s3_access_key_id
  aws_s3_secret_access_key = var.aws_s3_secret_access_key
  aws_sg_ec2_id            = module.create_network.aws_sg_ec2_id
  aws_subnet_one_id        = module.create_network.aws_subnet_one_id
  aws_lb_target_id         = module.create_network.aws_lb_target_id
  aws_sg_alb_id            = module.create_network.aws_sg_alb_id
  aws_dns_zone_id          = var.aws_dns_zone_id
}

module "create_cloudfront" {
  source = "./cloudfront"
  providers = {
    aws = aws.ttrpg
  }
  aws_region            = var.aws_region
  aws_dns_zone_id       = var.aws_dns_zone_id
  aws_lb_dns_name       = module.create_network.aws_lb_dns_name
  aws_lb_id             = module.create_network.aws_lb_id
  acm_certificate_arn   = var.certificate
}
