terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_efs_file_system" "efs-dr" {
  tags = {
    Name = "efs-dr"
  }
}

resource "aws_efs_mount_target" "mount-dr" {
  file_system_id  = aws_efs_file_system.efs-dr.id
  subnet_id       = var.aws_subnet_one_id
  security_groups = [var.aws_sg_alb_id]
}

resource "aws_ssm_parameter" "ttrpg_ssm_dr" {
  overwrite = true
  name      = "DR_EFS"
  type      = "String"
  value     = aws_efs_mount_target.mount-dr.ip_address
}

resource "aws_efs_file_system" "efs-dr-data" {
  tags = {
    Name = "efs-dr-data"
  }
}

resource "aws_efs_mount_target" "mount-dr-data" {
  file_system_id  = aws_efs_file_system.efs-dr-data.id
  subnet_id       = var.aws_subnet_one_id
  security_groups = [var.aws_sg_alb_id]
}

resource "aws_ssm_parameter" "ttrpg_ssm_dr_data" {
  overwrite = true
  name      = "DR_EFS_DATA"
  type      = "String"
  value     = aws_efs_mount_target.mount-dr-data.ip_address
}

resource "aws_datasync_location_efs" "dr_data" {
  efs_file_system_arn = aws_efs_mount_target.mount-dr-data.file_system_arn
  subdirectory        = "/data/"

  ec2_config {
    security_group_arns = [var.aws_sg_ec2_arn,var.aws_sg_alb_arn]
    subnet_arn          = var.aws_subnet_one_arn
  }
}

resource "aws_cloudwatch_log_group" "backup_dr" {
  name = "backup_dr"
}

resource "aws_datasync_task" "backup_dr_data" {
  destination_location_arn = var.s3_bucket_dr_task
  name                     = "backup_dr"
  source_location_arn      = aws_datasync_location_efs.dr_data.arn
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.backup_dr.arn

  options {
    bytes_per_second = -1
  }
}

resource "aws_cloudwatch_log_group" "restore_dr" {
  name = "restore_dr"
}

resource "aws_cloudwatch_log_stream" "restore_dr" {
  name           = "restore_dr"
  log_group_name = aws_cloudwatch_log_group.restore_dr.name
}

resource "aws_datasync_task" "restore_dr_data" {
  destination_location_arn = aws_datasync_location_efs.dr_data.arn
  name                     = "restore_dr"
  source_location_arn      = var.s3_bucket_dr_task
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.restore_dr.arn

  options {
    bytes_per_second = -1
  }
}

resource "aws_ssm_parameter" "ttrpg_ssm_dr_restore" {
  overwrite = true
  name      = "DR_TASK"
  type      = "String"
  value     = aws_datasync_task.restore_dr_data.arn
}

resource "aws_efs_file_system" "efs-ii" {
  tags = {
    Name = "efs-ii"
  }
}

resource "aws_efs_mount_target" "mount-ii" {
  file_system_id  = aws_efs_file_system.efs-ii.id
  subnet_id       = var.aws_subnet_one_id
  security_groups = [var.aws_sg_alb_id]
}

resource "aws_ssm_parameter" "ttrpg_ssm_ii" {
  overwrite = true
  name      = "II_EFS"
  type      = "String"
  value     = aws_efs_mount_target.mount-ii.ip_address
}

resource "aws_efs_file_system" "efs-pa" {
  tags = {
    Name = "efs-pa"
  }
}

resource "aws_efs_mount_target" "mount-pa" {
  file_system_id  = aws_efs_file_system.efs-pa.id
  subnet_id       = var.aws_subnet_one_id
  security_groups = [var.aws_sg_alb_id]
}

resource "aws_ssm_parameter" "ttrpg_ssm_pa" {
  overwrite = true
  name      = "PA_EFS"
  type      = "String"
  value     = aws_efs_mount_target.mount-pa.ip_address
}

resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = "ami-03aab79a35df660ba"
  iam_instance_profile = "ecs-agent"
  security_groups      = [var.aws_sg_alb_id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=ttrpg-cluster >> /etc/ecs/ecs.config"
  instance_type        = "t2.micro"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                      = "asg"
  vpc_zone_identifier       = [var.aws_subnet_one_id]
  launch_configuration      = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 5
  min_size                  = 5
  max_size                  = 8
  health_check_grace_period = 300
  health_check_type         = "EC2"
  capacity_rebalance        = true
}

resource "aws_service_discovery_private_dns_namespace" "ttrpg" {
  name        = "ttrpg.terraform.internal"
  description = "TTRPG container DNS"
  vpc         = var.aws_vpc_default_id
}

resource "aws_service_discovery_service" "nginx" {
  name = aws_ecs_task_definition.ttrpg-nginx-ecs-task-definition.family
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ttrpg.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 10
      type = "A"
    }
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "dungeon-revealer" {
  name = aws_ecs_task_definition.ttrpg-dr-ecs-task-definition.family
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ttrpg.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "improved-initiative" {
  name = aws_ecs_task_definition.ttrpg-ii-ecs-task-definition.family
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ttrpg.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "paragon" {
  name = aws_ecs_task_definition.ttrpg-pa-ecs-task-definition.family
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ttrpg.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "mongo" {
  name = aws_ecs_task_definition.ttrpg-mongo-ecs-task-definition.family
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ttrpg.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_ecs_cluster" "ttrpg-cluster" {
  name = "ttrpg-cluster"
}

resource "aws_cloudwatch_log_group" "nginx" {
  name = "nginx"
}

resource "aws_ecs_service" "ttrpg-nginx-ecs-service" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.ttrpg-cluster.id
  task_definition = aws_ecs_task_definition.ttrpg-nginx-ecs-task-definition.arn
  launch_type     = "EC2"

  desired_count = 1

  network_configuration {
    subnets          = [var.aws_subnet_one_id]
    security_groups  = [var.aws_sg_alb_id,var.aws_sg_ec2_id]
  }

  load_balancer {
    target_group_arn = var.aws_lb_target_id
    container_name   = "nginx"
    container_port   = 80
  }

  service_registries {
    registry_arn = aws_service_discovery_service.nginx.arn
    container_name = "nginx"
  }
}

resource "aws_ecs_task_definition" "ttrpg-nginx-ecs-task-definition" {
  family                   = "nginx"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  memory                   = "900"
  cpu                      = "900"

  volume {
    name = "efs-dr"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs-dr.id
      root_directory = "/build/"
    }
  }

  volume {
    name = "efs-ii"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs-ii.id
      root_directory = "/public/"
    }
  }

  volume {
    name = "efs-pa"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs-pa.id
      root_directory = "/build/"
    }
  }

  container_definitions    = <<EOF
[
  {
    "name": "nginx",
    "image": "${var.nginx_repo_url}:latest",
    "memory": 900,
    "cpu": 900,
    "essential": true,
    "workingDirectory": "/",
    "command": ["bash", "-c", "NGINX_ENVSUBST_TEMPLATE_DIR=/etc/nginx NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx /docker-entrypoint.d/20-envsubst-on-templates.sh && NGINX_ENVSUBST_TEMPLATE_DIR=/etc/nginx/conf.d NGINX_ENVSUBST_OUTPUT_DIR=/etc/nginx/conf.d /docker-entrypoint.d/20-envsubst-on-templates.sh && sudo nginx -g 'daemon off;'"],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      },
      {
        "containerPort": 443,
        "hostPort": 443,
        "protocol": "tcp"
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/var/www/dungeon-revealer/",
        "sourceVolume": "efs-dr"
      },
      {
        "containerPath": "/var/www/improved-initiative/",
        "sourceVolume": "efs-ii"
      },
      {
        "containerPath": "/var/www/paragon/",
        "sourceVolume": "efs-pa"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "nginx",
            "awslogs-region": "us-east-2",
            "awslogs-stream-prefix": "nginx"
        }
    },
    "environment": [
      {
        "name": "HTACCESS",
        "value": "${data.aws_ssm_parameter.htaccess.value}"
      },
      {
        "name": "DOMAIN",
        "value": "${data.aws_ssm_parameter.domain.value}"
      },
      {
        "name": "DR_HOST",
        "value": "${data.aws_ssm_parameter.dr_host.value}"
      },
      {
        "name": "DR_HOST_CN",
        "value": "${data.aws_ssm_parameter.dr_host_cn.value}"
      },
      {
        "name": "PA_HOST",
        "value": "${data.aws_ssm_parameter.pa_host.value}"
      },
      {
        "name": "PA_HOST_CN",
        "value": "${data.aws_ssm_parameter.pa_host_cn.value}"
      },
      {
        "name": "II_HOST",
        "value": "${data.aws_ssm_parameter.ii_host.value}"
      },
      {
        "name": "II_HOST_CN",
        "value": "${data.aws_ssm_parameter.ii_host_cn.value}"
      },
      {
        "name": "SSL",
        "value": "nossl"
      },
      {
        "name": "RESOLVER",
        "value": "${data.aws_ssm_parameter.resolver.value}"
      }
    ]
  }
]
EOF
}

resource "aws_cloudwatch_log_group" "dr" {
  name = "dr"
}

resource "aws_ecs_service" "ttrpg-dr-ecs-service" {
  name            = "dungeon-revealer"
  cluster         = aws_ecs_cluster.ttrpg-cluster.id
  task_definition = aws_ecs_task_definition.ttrpg-dr-ecs-task-definition.arn
  launch_type     = "EC2"

  desired_count = 1

  network_configuration {
    subnets          = [var.aws_subnet_one_id]
    security_groups  = [var.aws_sg_ec2_id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.dungeon-revealer.arn
    container_name = "dungeon-revealer"
  }
}

resource "aws_ecs_task_definition" "ttrpg-dr-ecs-task-definition" {
  family                   = "dungeon-revealer"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  memory                   = "900"
  cpu                      = "900"

  volume {
    name = "efs-dr-data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs-dr-data.id
      root_directory = "/data/"
    }
  }

  volume {
    name = "efs-dr"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs-dr.id
      root_directory = "/build/"
    }
  }

  container_definitions    = <<EOF
[
  {
    "name": "dungeon-revealer",
    "image": "${var.dr_repo_url}:latest",
    "memory": 512,
    "cpu": 512,
    "essential": true,
    "workingDirectory": "/usr/src/app",
    "command": [ "/bin/sh", "-c", "node server-build/index.js"],
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000,
        "protocol": "tcp"
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/usr/src/app/data/",
        "sourceVolume": "efs-dr-data"
      },
      {
        "containerPath": "/usr/src/app/build/",
        "sourceVolume": "efs-dr"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "dr",
            "awslogs-region": "us-east-2",
            "awslogs-stream-prefix": "dr"
        }
    },
    "environment": [
      {
        "name": "PC_PASSWORD",
        "value": "${data.aws_ssm_parameter.dr_user_pass.value}"
      },
      {
        "name": "DM_PASSWORD",
        "value": "${data.aws_ssm_parameter.dr_dm_pass.value}"
      },
      {
        "name": "PUBLIC_URL",
        "value": "https://${data.aws_ssm_parameter.dr_host.value}.${data.aws_ssm_parameter.domain.value}"
      }
    ]
  }
]
EOF
}

resource "aws_cloudwatch_log_group" "ii" {
  name = "ii"
}

resource "aws_ecs_service" "ttrpg-ii-ecs-service" {
  name            = "improved-initiative"
  cluster         = aws_ecs_cluster.ttrpg-cluster.id
  task_definition = aws_ecs_task_definition.ttrpg-ii-ecs-task-definition.arn
  launch_type     = "EC2"

  desired_count = 1

  network_configuration {
    subnets          = [var.aws_subnet_one_id]
    security_groups  = [var.aws_sg_ec2_id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.improved-initiative.arn
    container_name = "improved-initiative"
  }
}

resource "aws_ecs_task_definition" "ttrpg-ii-ecs-task-definition" {
  family                   = "improved-initiative"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  memory                   = "900"
  cpu                      = "900"

  volume {
    name = "efs-ii"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs-ii.id
      root_directory = "/public/"
    }
  }

  container_definitions    = <<EOF
[
  {
    "name": "improved-initiative",
    "image": "${var.ii_repo_url}:latest",
    "memory": 512,
    "cpu": 512,
    "essential": true,
    "workingDirectory": "/usr/src/app",
    "command": ["/bin/bash", "-c", "node server/server.js"],
    "portMappings": [
      {
        "containerPort": 4000,
        "hostPort": 4000,
        "protocol": "tcp"
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/usr/src/app/public/",
        "sourceVolume": "efs-ii"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "ii",
            "awslogs-region": "us-east-2",
            "awslogs-stream-prefix": "ii"
        }
    },
    "environment": [
      {
        "name": "PORT",
        "value": "4000"
      },
      {
        "name": "DB_CONNECTION_STRING",
        "value": "mongodb://mongo.ttrpg.terraform.internal:27017/"
      }
    ]
  }
]
EOF
}

resource "aws_cloudwatch_log_group" "pa" {
  name = "pa"
}

resource "aws_ecs_service" "ttrpg-pa-ecs-service" {
  name            = "paragon"
  cluster         = aws_ecs_cluster.ttrpg-cluster.id
  task_definition = aws_ecs_task_definition.ttrpg-pa-ecs-task-definition.arn
  launch_type     = "EC2"

  desired_count = 1

  network_configuration {
    subnets          = [var.aws_subnet_one_id]
    security_groups  = [var.aws_sg_ec2_id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.paragon.arn
    container_name = "paragon"
  }
}

resource "aws_ecs_task_definition" "ttrpg-pa-ecs-task-definition" {
  family                   = "paragon"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  memory                   = "900"
  cpu                      = "900"

  volume {
    name = "efs-pa"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs-pa.id
      root_directory = "/build/"
    }
  }

  container_definitions    = <<EOF
[
  {
    "name": "paragon",
    "image": "${var.pa_repo_url}:latest",
    "memory": 512,
    "cpu": 512,
    "essential": true,
    "workingDirectory": "/usr/src/app",
    "command": ["/bin/sh", "-c", "export PATH=$PATH:/home/node/.npm-global/bin/ && serve -s build -l 3000"],
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000,
        "protocol": "tcp"
      }
    ],
    "mountPoints": [
      {
        "containerPath": "/usr/src/app/build/",
        "sourceVolume": "efs-pa"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "pa",
            "awslogs-region": "us-east-2",
            "awslogs-stream-prefix": "pa"
        }
    }
  }
]
EOF
}

resource "aws_cloudwatch_log_group" "mongo" {
  name = "mongo"
}

resource "aws_ecs_service" "ttrpg-mongo-ecs-service" {
  name            = "mongo"
  cluster         = aws_ecs_cluster.ttrpg-cluster.id
  task_definition = aws_ecs_task_definition.ttrpg-mongo-ecs-task-definition.arn
  launch_type     = "EC2"

  desired_count = 1

  network_configuration {
    subnets          = [var.aws_subnet_one_id]
    security_groups  = [var.aws_sg_ec2_id]
  }

  service_registries {
    registry_arn = aws_service_discovery_service.mongo.arn
    container_name = "mongo"
  }
}

resource "aws_ecs_task_definition" "ttrpg-mongo-ecs-task-definition" {
  family                   = "mongo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  memory                   = "900"
  cpu                      = "900"

  container_definitions    = <<EOF
[
  {
    "name": "mongo",
    "image": "${var.mongo_repo_url}:latest",
    "memory": 512,
    "cpu": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 27017,
        "hostPort": 27017,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "mongo",
            "awslogs-region": "us-east-2",
            "awslogs-stream-prefix": "mongo"
        }
    },
    "environment": [
      {
        "name": "MONGO_INITDB_ROOT_USERNAME",
        "value": "${data.aws_ssm_parameter.mongo_user.value}"
      },
      {
        "name": "MONGO_INITDB_ROOT_PASSWORD",
        "value": "${data.aws_ssm_parameter.mongo_pass.value}"
      }
    ]
  }
]
EOF
}

#resource "aws_docdb_subnet_group" "ttrpg" {
#  name       = "ttrpg-group"
#  subnet_ids = [var.aws_subnet_one_id,var.aws_subnet_two_id]
#}
#
#resource "aws_docdb_cluster" "ttrpg-mongo" {
#  cluster_identifier              = "ttrpg-mongo"
#  engine                          = "docdb"
#  master_username                 = data.aws_ssm_parameter.mongo_user.value
#  master_password                 = data.aws_ssm_parameter.mongo_pass.value
#  vpc_security_group_ids          = [var.aws_sg_ec2_id]
#  port                            = "27017"
#  db_subnet_group_name            = aws_docdb_subnet_group.ttrpg.name
#  skip_final_snapshot             = true
#  backup_retention_period         = 1
#  apply_immediately               = true
#  enabled_cloudwatch_logs_exports = ["audit","profiler"]
#}

#resource "aws_docdb_cluster_instance" "ttrpg-mongo-instances" {
#  count              = 1
#  identifier         = "docdb-cluster-ttrpg-${count.index}"
#  cluster_identifier = aws_docdb_cluster.ttrpg-mongo.id
# instance_class     = "db.t3.medium"
#}
