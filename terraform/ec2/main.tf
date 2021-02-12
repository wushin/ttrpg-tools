terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  public_key_filename  = "${var.sshpath}/${var.public_key_name}"
  private_key_filename = "${var.sshpath}/${var.private_key_name}"
}

resource "aws_key_pair" "imported" {
  key_name   = var.private_key_name
  public_key = file(local.public_key_filename)
}

resource "aws_instance" "ttrpgserver" {
  ami                    = "ami-05f5cd6454a382a70"
  instance_type          = var.instance_type
  key_name               = var.private_key_name
  vpc_security_group_ids = [var.aws_sg_ec2_id]
  subnet_id              = var.aws_subnet_one_id

  root_block_device {
    volume_size           = 30
  }

  connection {
    type        = "ssh"
    user        = "admin"
    host        = aws_instance.ttrpgserver.public_ip
    private_key = file(local.private_key_filename)
  }

  provisioner "file" {
    source      = local.private_key_filename
    destination = "/home/admin/.ssh/${var.private_key_name}"
  }

  provisioner "file" {
    source      = "${var.module_depth}.env"
    destination = "/home/admin/.env"
  }

  provisioner "file" {
    source      = "${var.module_depth}aws_install.sh"
    destination = "/home/admin/aws_install.sh"
  }

  provisioner "file" {
    source      = "${var.module_depth}linux_install.sh"
    destination = "/home/admin/linux_install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/admin/.ssh/${var.private_key_name}",
      "chmod +x /home/admin/linux_install.sh /home/admin/aws_install.sh",
      "/home/admin/linux_install.sh",
      "/home/admin/aws_install.sh ${var.private_key_name} ${var.aws_region} ${var.aws_s3_access_key_id} ${var.aws_s3_secret_access_key} ${var.git_user}",
      "cd /home/admin/ttrpg-tools/ && make build",
    ]
  }

  tags = {
    Name = "ttrpgtools-serve"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = var.aws_lb_target_id
  target_id        = aws_instance.ttrpgserver.id
  port             = 80
}
