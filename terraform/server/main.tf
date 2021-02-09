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
  subnet_id              = aws_subnet.default.id

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

resource "aws_subnet" "default" {
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
  subnets            = [aws_subnet.default.id,aws_subnet.default_two.id]
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

resource "aws_cloudfront_distribution" "ttrpg_distribution" {
  origin {
    domain_name = aws_lb.web.dns_name
    origin_id   = aws_lb.web.id

    custom_origin_config {
      origin_read_timeout      = 30
      origin_keepalive_timeout = 30
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only"
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = ""

  logging_config {
    include_cookies = false
    bucket          = "ttrpg-terraform-bucket.s3.amazonaws.com"
    prefix          = "logs_"
  }

  aliases = ["${var.dr_hostname}.${var.domain_name}","${var.ii_hostname}.${var.domain_name}","${var.pa_hostname}.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_lb.web.id

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
      headers = [
        "*",
      ]

    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = {
    Name = "ttrpgtools-cloudfront"
  }

  viewer_certificate {
    acm_certificate_arn            = var.cert_arn
    cloudfront_default_certificate = false
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
  }
}
