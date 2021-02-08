output "public_ip" {
  value       = aws_instance.ttrpgserver.public_ip
  description = "The public IP of the ttrpgtools server"
}
