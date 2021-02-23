terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_ecr_repository" "ttrpg-nginx" {
  name                 = "nginx"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker tag ttrpg-tools_nginx ${aws_ecr_repository.ttrpg-nginx.repository_url}:latest"
  }
  provisioner "local-exec" {
    when = create
    command = "aws --profile ttrpg ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.ttrpg-nginx.repository_url}"
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker push ${aws_ecr_repository.ttrpg-nginx.repository_url}:latest"
  }
}

resource "aws_ecr_repository" "ttrpg-dr" {
  name                 = "dungeon-revealer"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker tag ttrpg-tools_dungeon-revealer ${aws_ecr_repository.ttrpg-dr.repository_url}:latest"
  }
  provisioner "local-exec" {
    when = create
    command = "aws --profile ttrpg ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.ttrpg-dr.repository_url}"
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker push ${aws_ecr_repository.ttrpg-dr.repository_url}:latest"
  }
}

resource "aws_ecr_repository" "ttrpg-ii" {
  name                 = "improved-initiative"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker tag ttrpg-tools_improved-initiative ${aws_ecr_repository.ttrpg-ii.repository_url}:latest"
  }
  provisioner "local-exec" {
    when = create
    command = "aws --profile ttrpg ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.ttrpg-ii.repository_url}"
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker push ${aws_ecr_repository.ttrpg-ii.repository_url}:latest"
  }
}

resource "aws_ecr_repository" "ttrpg-pa" {
  name                 = "paragon"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker tag ttrpg-tools_paragon ${aws_ecr_repository.ttrpg-pa.repository_url}:latest"
  }
  provisioner "local-exec" {
    when = create
    command = "aws --profile ttrpg ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.ttrpg-pa.repository_url}"
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker push ${aws_ecr_repository.ttrpg-pa.repository_url}:latest"
  }
}

resource "aws_ecr_repository" "ttrpg-mongo" {
  name                 = "mongo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker tag mongo ${aws_ecr_repository.ttrpg-mongo.repository_url}:latest"
  }
  provisioner "local-exec" {
    when = create
    command = "aws --profile ttrpg ecr get-login-password --region ${var.aws_region} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.ttrpg-pa.repository_url}"
  }
  provisioner "local-exec" {
    when = create
    command = "sudo docker push ${aws_ecr_repository.ttrpg-mongo.repository_url}:latest"
  }
}
