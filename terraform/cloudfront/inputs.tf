data "aws_ssm_parameter" "domain" {
  name = "DOMAIN"
}
data "aws_ssm_parameter" "dr_host" {
  name = "DR_HOST"
}
data "aws_ssm_parameter" "ii_host" {
  name = "II_HOST"
}
data "aws_ssm_parameter" "pa_host" {
  name = "PA_HOST"
}
