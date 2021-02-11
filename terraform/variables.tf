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
variable "domain_name" {
  description = "Domain Name"
  type        = string
}
variable "enable_acm_cloudfront" {
  description = "Whether or not to use cloudfront"
  type        = bool
}
variable "enable_aws_dns" {
  description = "Turns AWS DNS route adding off"
  type        = bool
}
variable "use_dns_method" {
  description = "Which method DNS or EMAIL for validation"
  type        = bool
}
variable "aws_dns_zone_id" {
  description = "Route53 zone file ID"
  type        = string
}
variable "dr_hostname" {
  description = "Dungeon Revealer Host Name"
  type        = string
}
variable "ii_hostname" {
  description = "Improved Initiative Host Name"
  type        = string
}
variable "pa_hostname" {
  description = "Paragon Host Name"
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
