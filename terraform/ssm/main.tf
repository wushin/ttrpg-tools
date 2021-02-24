provider "aws" {
  region  = var.aws_region
  profile = "ttrpg"
}

locals {
  docker_env = [for line in compact(split("\n", file("${var.module_depth}.env"))) : split("=",line)]
}

resource "aws_ssm_parameter" "ttrpg_ssm" {
  overwrite = true
  count     = length(local.docker_env)
  name      = local.docker_env[count.index][0]
  type      = length(regexall("PASS", local.docker_env[count.index][0])) > 0 ? "SecureString" : "String"
  value     = length(regexall("_CN", local.docker_env[count.index][0])) > 0 ? "${local.docker_env[count.index][1]}.ttrpg.terraform.internal" : local.docker_env[count.index][1]
}
