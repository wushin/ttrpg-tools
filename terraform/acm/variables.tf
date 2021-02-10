variable "domain_name" {
  description = "Domain Name"
  type        = string
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
