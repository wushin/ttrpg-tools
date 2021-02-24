variable "aws_region" {
  description = "Region services should spawn in"
  type        = string
}
variable "module_depth" {
  description = "Where are we in relation to the root of repo"
  type        = string
}
variable "aws_vpc_default_id" {
  description = "Default VPC"
  type        = string
}
variable "aws_sg_ec2_id" {
  description = "ec2 autoscaling group"
  type        = string
}
variable "aws_sg_alb_id" {
  description = "ec2 alb group"
  type        = string
}
variable "aws_lb_target_id" {
  description = "ec2 loadbalancer target group"
  type        = string
}
variable "aws_subnet_one_id" {
  description = "ec2 subnet id"
  type        = string
}
variable "aws_subnet_four_id" {
  description = "ec2 subnet id"
  type        = string
}
variable "nginx_repo_url" {
  description = "ECR nginx repo"
  type        = string
}
variable "dr_repo_url" {
  description = "ECR dr repo"
  type        = string
}
variable "ii_repo_url" {
  description = "ECR ii repo"
  type        = string
}
variable "pa_repo_url" {
  description = "ECR pa repo"
  type        = string
}
