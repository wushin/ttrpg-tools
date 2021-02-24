variable "aws_region" {
  description = "Region services should spawn in"
  type        = string
}
variable "module_depth" {
  description = "Where are we in relation to the root of repo"
  type        = string
}
variable "s3_lb_bucket" {
  description = "S3 Bucket"
  type        = string
}
