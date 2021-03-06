variable "aws_region" {
  description = "Region services should spawn in"
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
variable "restore_from_local" {
  description = "Whether or not to restore from this local build"
  type        = bool
}
variable "aws_dns_zone_id" {
  description = "Route53 zone file ID"
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
variable "certificate" {
  description = "AWS Certificate ARN"
  type        = string
}
