data "aws_ssm_parameter" "dr_efs" {
  name = "DR_EFS"
}
data "aws_ssm_parameter" "dr_efs_data" {
  name = "DR_EFS_DATA"
}
data "aws_ssm_parameter" "ii_efs" {
  name = "II_EFS"
}
data "aws_ssm_parameter" "pa_efs" {
  name = "PA_EFS"
}
