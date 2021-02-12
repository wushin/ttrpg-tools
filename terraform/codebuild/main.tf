# Codebuild execution role data
resource "aws_iam_role" "codebuild_execution_role" {
  name = "codebuilder"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_execution_role.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
        "ecr:GetAuthorizationToken",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:BatchCheckLayerAvailability",
        "ecs:UpdateService",
        "ecr:PutImage",
        "datasync:StartTaskExecution",
        "datasync:DescribeTaskExecution"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:us-east-1::network-interface/*",
        "arn:aws:ec2:us-east-1::subnet/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": [
            "${var.aws_subnet_one_id}"
          ],
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_codebuild_project" "ttrpg-tools-codebuild-dr" {
  name          = "ttrpg-tools-dr"
  description   = "Dungeon Revealer Codebuild"
  build_timeout = "60"
  service_role  = aws_iam_role.codebuild_execution_role.name

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "PC_PASSWORD"
      value = data.aws_ssm_parameter.dr_user_pass.value
    }

    environment_variable {
      name  = "DM_PASSWORD"
      value = data.aws_ssm_parameter.dr_dm_pass.value
    }

    environment_variable {
      name  = "PUBLIC_URL"
      value = "/map"
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "REPOURL"
      value = var.dr_repo_url
    }

    environment_variable {
      name  = "DR_EFS"
      value = data.aws_ssm_parameter.dr_efs.value
    }

    environment_variable {
      name  = "DR_EFS_DATA"
      value = data.aws_ssm_parameter.dr_efs_data.value
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "ttrpg-codebuild-dr"
      stream_name = "log-dr"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/wushin/ttrpg-tools.git"
    buildspec       = "dr-build.yml"
    git_clone_depth = 5

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "containers-clusters-oh-my"

  vpc_config {
    vpc_id = var.aws_vpc_default_id

    subnets = [
      var.aws_subnet_four_id
    ]

    security_group_ids = [
      var.aws_sg_ec2_id,
      var.aws_sg_alb_id
    ]
  }
}

resource "aws_codebuild_project" "ttrpg-tools-codebuild-ii" {
  name          = "ttrpg-tools-ii"
  description   = "Improved Initiative Codebuild"
  build_timeout = "60"
  service_role  = aws_iam_role.codebuild_execution_role.name

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "PORT"
      value = "4000"
    }

    environment_variable {
      name  = "DB_CONNECTION_STRING"
      value = "mongodb://mongo.ttrpg.terraform.internal:27017/"
    }

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "REPOURL"
      value = var.ii_repo_url
    }

    environment_variable {
      name  = "II_EFS"
      value = data.aws_ssm_parameter.ii_efs.value
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "ttrpg-codebuild-ii"
      stream_name = "log-ii"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/wushin/ttrpg-tools.git"
    buildspec       = "ii-build.yml"
    git_clone_depth = 5

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "containers-clusters-oh-my"

  vpc_config {
    vpc_id = var.aws_vpc_default_id

    subnets = [
      var.aws_subnet_four_id
    ]

    security_group_ids = [
      var.aws_sg_ec2_id,
      var.aws_sg_alb_id
    ]
  }
}

resource "aws_codebuild_project" "ttrpg-tools-codebuild-pa" {
  name          = "ttrpg-tools-pa"
  description   = "Paragon Codebuild"
  build_timeout = "60"
  service_role  = aws_iam_role.codebuild_execution_role.name

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "REPOURL"
      value = var.pa_repo_url
    }

    environment_variable {
      name  = "PA_EFS"
      value = data.aws_ssm_parameter.pa_efs.value
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "ttrpg-codebuild-pa"
      stream_name = "log-pa"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/wushin/ttrpg-tools.git"
    buildspec       = "pa-build.yml"
    git_clone_depth = 5

    git_submodules_config {
      fetch_submodules = true
    }
  }

  source_version = "containers-clusters-oh-my"

  vpc_config {
    vpc_id = var.aws_vpc_default_id

    subnets = [
      var.aws_subnet_four_id
    ]

    security_group_ids = [
      var.aws_sg_ec2_id,
      var.aws_sg_alb_id
    ]
  }
}

resource "aws_codebuild_project" "ttrpg-tools-codebuild-nginx" {
  name          = "ttrpg-tools-nginx"
  description   = "Nginx Codebuild"
  build_timeout = "60"
  service_role  = aws_iam_role.codebuild_execution_role.name

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "REPOURL"
      value = var.nginx_repo_url
    }

    environment_variable {
      name  = "HTACCESS"
      value = data.aws_ssm_parameter.htaccess.value
    }

    environment_variable {
      name  = "HT_USER"
      value = data.aws_ssm_parameter.ht_user.value
    }

    environment_variable {
      name  = "DR_USER_PASS"
      value = data.aws_ssm_parameter.dr_user_pass.value
    }

    environment_variable {
      name  = "HT_DM_USER"
      value = data.aws_ssm_parameter.ht_dm_user.value
    }

    environment_variable {
      name  = "DR_DM_PASS"
      value = data.aws_ssm_parameter.dr_dm_pass.value
    }

    environment_variable {
      name  = "DOMAIN"
      value = data.aws_ssm_parameter.domain.value
    }

    environment_variable {
      name  = "DOMAIN_EMAIL"
      value = data.aws_ssm_parameter.domain_email.value
    }

    environment_variable {
      name  = "DR_HOST"
      value = data.aws_ssm_parameter.dr_host.value
    }

    environment_variable {
      name  = "DR_HOST_CN"
      value = data.aws_ssm_parameter.dr_host_cn.value
    }

    environment_variable {
      name  = "II_HOST"
      value = data.aws_ssm_parameter.ii_host.value
    }

    environment_variable {
      name  = "II_HOST_CN"
      value = data.aws_ssm_parameter.ii_host_cn.value
    }

    environment_variable {
      name  = "PA_HOST"
      value = data.aws_ssm_parameter.pa_host.value
    }

    environment_variable {
      name  = "PA_HOST_CN"
      value = data.aws_ssm_parameter.pa_host_cn.value
    }

    environment_variable {
      name  = "SSL"
      value = data.aws_ssm_parameter.ssl.value
    }

    environment_variable {
      name  = "NGINX_EFS"
      value = data.aws_ssm_parameter.nginx_efs.value
    }

    environment_variable {
      name  = "RESOLVER"
      value = data.aws_ssm_parameter.resolver.value
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "ttrpg-codebuild-nginx"
      stream_name = "log-nginx"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/wushin/ttrpg-tools.git"
    buildspec       = "nginx-build.yml"
    git_clone_depth = 5

    git_submodules_config {
      fetch_submodules = false
    }
  }

  source_version = "containers-clusters-oh-my"

  vpc_config {
    vpc_id = var.aws_vpc_default_id

    subnets = [
      var.aws_subnet_four_id
    ]

    security_group_ids = [
      var.aws_sg_ec2_id,
      var.aws_sg_alb_id
    ]
  }
}

resource "aws_codebuild_project" "ttrpg-tools-codebuild-dr-restore" {
  name          = "ttrpg-tools-dr-restore"
  description   = "Dungeon Revealer Restore"
  build_timeout = "60"
  service_role  = aws_iam_role.codebuild_execution_role.name

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:2.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "DR_TASK"
      value = data.aws_ssm_parameter.dr_task.value
    }

    environment_variable {
      name  = "DR_EFS_DATA"
      value = data.aws_ssm_parameter.dr_efs_data.value
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "ttrpg-codebuild-dr-restore"
      stream_name = "log-dr-restore"
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/wushin/ttrpg-tools.git"
    buildspec       = "dr-restore.yml"
    git_clone_depth = 5

    git_submodules_config {
      fetch_submodules = false
    }
  }

  source_version = "containers-clusters-oh-my"

  vpc_config {
    vpc_id = var.aws_vpc_default_id

    subnets = [
      var.aws_subnet_four_id
    ]

    security_group_ids = [
      var.aws_sg_ec2_id,
      var.aws_sg_alb_id
    ]
  }
}
