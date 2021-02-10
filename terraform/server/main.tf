provider "aws" {
  region  = var.aws_region
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
  subnet_id              = aws_subnet.default_one.id

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
    source      = "../../.env"
    destination = "/home/admin/.env"
  }

  provisioner "file" {
    source      = "../../aws_install.sh"
    destination = "/home/admin/aws_install.sh"
  }

  provisioner "file" {
    source      = "../../linux_install.sh"
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

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.default.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_subnet" "default_one" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = format("%sa", var.aws_region)
}

resource "aws_subnet" "default_two" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = format("%sb", var.aws_region)
}

resource "aws_subnet" "default_three" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = format("%sc", var.aws_region)
}

resource "aws_security_group" "alb" {
  name        = "ttrpgtools_alb"
  description = "Used in the terraform"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_lb" "web" {
  name               = "ttrpgtools-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.default_one.id,aws_subnet.default_two.id,aws_subnet.default_three.id]
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ttrpgtools.arn
  }
}

resource "aws_lb_target_group" "ttrpgtools" {
  name          = "ttrpgtools-lb-tg"
  port          = 80
  protocol      = "HTTP"
  health_check {
    path        = "/nginx-health"
  }
  vpc_id        = aws_vpc.default.id
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.ttrpgtools.arn
  target_id        = aws_instance.ttrpgserver.id
  port             = 80
}

resource "aws_security_group" "instance" {
  name          = "ttrpgtools-serve-instance"
  vpc_id        = aws_vpc.default.id
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
