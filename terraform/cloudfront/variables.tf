variable "aws_region" {
  description = "Region services should spawn in"
  type        = string
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
