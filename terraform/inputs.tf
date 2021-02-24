data "aws_ssm_parameter" "domain" {
  provider = aws.ttrpg
  name = "DOMAIN"
}
data "aws_ssm_parameter" "dr_host" {
  provider = aws.ttrpg
  name = "DR_HOST"
}
data "aws_ssm_parameter" "ii_host" {
  provider = aws.ttrpg
  name = "II_HOST"
}
data "aws_ssm_parameter" "pa_host" {
  provider = aws.ttrpg
  name = "PA_HOST"
}
