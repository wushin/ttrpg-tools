variable "aws_region" {
  description = "Region services should spawn in"
  type        = string
}
variable "module_depth" {
  description = "Where are we in relation to the root of repo"
  type        = string
}
variable "instance_type" {
  description = "What size of ec2 server to run on"
  type        = string
}
variable "sshpath" {
  description = "Path to a directory where the public and private SSH key will be stored."
  type        = string
}
variable "private_key_name" {
  description = "SSH Private Key filename you want to use"
  type        = string
}
variable "public_key_name" {
  description = "SSH Public Key filename you want to use"
  type        = string
}
variable "git_user" {
  description = "Github account"
  type        = string
}
variable "aws_s3_access_key_id" {
  description = "AWS s3 Access Key Id"
  type        = string
}
variable "aws_s3_secret_access_key" {
  description = "AWS s3 Secret Access Key"
  type        = string
}
variable "aws_sg_ec2_id" {
  description = "AWS Security Group for ec2 instance"
  type        = string
}
variable "aws_subnet_one_id" {
  description = "ec2 subnet id"
  type        = string
}
variable "aws_lb_target_id" {
  description = "ec2 loadbalancer target group"
  type        = string
}
variable "aws_sg_alb_id" {
  description = "ec2 loadbalancer target group"
  type        = string
}
variable "aws_dns_zone_id" {
  description = "DNS zone id"
  type        = string
}
