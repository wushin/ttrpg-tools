provider "aws" {
  region = var.aws_region
  profile = "ttrpg"
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
  vpc_security_group_ids = [aws_security_group.instance.id]

  root_block_device {
    volume_size           = 20
    delete_on_termination = false
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
    source      = "../../.env"
    destination = "/home/admin/.env"
  }

  provisioner "file" {
    source      = "../../linux_install.sh"
    destination = "/home/admin/linux_install.sh"
  }

  provisioner "file" {
    source      = "../../update_dns.sh"
    destination = "/home/admin/update_dns.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/admin/linux_install.sh",
      "chmod 600 /home/admin/.ssh/${var.private_key_name}",
      "/home/admin/linux_install.sh ${var.private_key_name} ${var.domain_service} ${var.aws_region} ${var.aws_access_key_id} ${var.aws_secret_access_key}",
    ]
  }

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
