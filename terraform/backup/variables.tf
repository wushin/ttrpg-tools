variable "aws_region" {
  description = "Region services should spawn in"
  type        = string
}
variable "module_depth" {
  description = "Where are we in relation to the root of repo"
  type        = string
}
variable "restore_from_local" {
  description = "Whether or not to restore from this local build"
  type        = bool
}
