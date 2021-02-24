variable "aws_region" {
  description = "AWS Region"
  type        = string
}
variable "domain_name" {
  description = "Domain Name"
  type        = string
}
variable "domain_email" {
  description = "Domain Email"
  type        = string
}
variable "aws_dns_zone_id" {
  description = "Route53 zone file ID"
  type        = string
}
