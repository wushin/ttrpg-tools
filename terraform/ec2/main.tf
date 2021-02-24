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
  vpc_security_group_ids = [var.aws_sg_ec2_id,var.aws_sg_alb_id]
  subnet_id              = var.aws_subnet_one_id

  root_block_device {
    volume_size           = 30
  }

  connection {
    type        = "ssh"
    user        = "admin"
    host        = self.public_ip
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
      "mkdir -p /home/admin/ttrpg-mounts/dr_data",
      "mkdir -p /home/admin/ttrpg-mounts/dr",
      "mkdir -p /home/admin/ttrpg-mounts/ii",
      "mkdir -p /home/admin/ttrpg-mounts/pa",
      "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${data.aws_ssm_parameter.dr_efs_data.value}:/ /home/admin/ttrpg-mounts/dr_data/",
      "sudo su -c \"echo '${data.aws_ssm_parameter.dr_efs_data.value}:/ /home/admin/ttrpg-mounts/dr_data/ nfs defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab \"",
      "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${data.aws_ssm_parameter.dr_efs.value}:/ /home/admin/ttrpg-mounts/dr/",
      "sudo su -c \"echo '${data.aws_ssm_parameter.dr_efs.value}:/ /home/admin/ttrpg-mounts/dr/ nfs defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab \"",
      "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${data.aws_ssm_parameter.pa_efs.value}:/ /home/admin/ttrpg-mounts/pa/",
      "sudo su -c \"echo '${data.aws_ssm_parameter.pa_efs.value}:/ /home/admin/ttrpg-mounts/pa/ nfs defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab \"",
      "sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${data.aws_ssm_parameter.ii_efs.value}:/ /home/admin/ttrpg-mounts/ii/",
      "sudo su -c \"echo '${data.aws_ssm_parameter.ii_efs.value}:/ /home/admin/ttrpg-mounts/ii/ nfs defaults,vers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0' >> /etc/fstab \"",
    ]
  }

  tags = {
    Name = "ttrpgtools-bastion"
  }
}

resource "aws_route53_record" "bastion" {
  zone_id = var.aws_dns_zone_id
  name    = "bastion"
  type    = "A"
  ttl     = "60"

  records = [aws_instance.ttrpgserver.public_ip]
}
