variable "aws_region" {
  description = "Region services should spawn in"
  type        = string
}
variable "domain_name" {
  description = "Domain Name"
  type        = string
}
variable "enable_aws_dns" {
  description = "Turns AWS DNS route adding off"
  type        = bool
}
variable "aws_dns_zone_id" {
  description = "Route53 zone file ID"
  type        = string
}
variable "aws_lb_dns_name" {
  description = "aws load balancer dns name"
  type        = string
}
variable "aws_lb_id" {
  description = "aws load balancer id"
  type        = string
}
variable "acm_certificate_arn" {
  description = "ACM certificate ARN"
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
