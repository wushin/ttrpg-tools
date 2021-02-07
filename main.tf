provider "aws" {
  region = "us-east-2"
}

locals {
  public_key_filename  = "${var.sshpath}/ttrpgtools.pub"
  private_key_filename = "${var.sshpath}/ttrpgtools.pem"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  public_key = tls_private_key.generated.public_key_openssh
}

resource "tls_private_key" "generated" {
  algorithm = "RSA"
}

resource "aws_key_pair" "generated" {
  key_name   = "ttrpgserve"
  public_key = tls_private_key.generated.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}

resource "local_file" "public_key_openssh" {
  count    = var.sshpath != "" ? 1 : 0
  content  = tls_private_key.generated.public_key_openssh
  filename = local.public_key_filename
}

resource "local_file" "private_key_pem" {
  count    = var.sshpath != "" ? 1 : 0
  content  = tls_private_key.generated.private_key_pem
  filename = local.private_key_filename
}

resource "null_resource" "chmod_pub" {
  count      = var.sshpath != "" ? 1 : 0
  depends_on = [local_file.public_key_openssh]

  triggers = {
    key = tls_private_key.generated.public_key_openssh
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local.public_key_filename}"
  }
}

resource "null_resource" "chmod_pem" {
  count      = var.sshpath != "" ? 1 : 0
  depends_on = [local_file.private_key_pem]

  triggers = {
    key = tls_private_key.generated.private_key_pem
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local.private_key_filename}"
  }
}

resource "aws_instance" "ttrpgserver" {
  ami           = "ami-05f5cd6454a382a70"
  instance_type = "t2.micro"
  key_name = "ttrpgserve"
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = "ttrpgtools-serve"
  }
}

resource "aws_security_group" "instance" {
  name = "ttrpgtools-serve-instance"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
