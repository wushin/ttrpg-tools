data "aws_ssm_parameter" "domain" {
  name = "DOMAIN"
}
data "aws_ssm_parameter" "domain_email" {
  name = "DOMAIN_EMAIL"
}
data "aws_ssm_parameter" "dr_host" {
  name = "DR_HOST"
}
data "aws_ssm_parameter" "dr_host_cn" {
  name = "DR_HOST_CN"
}
data "aws_ssm_parameter" "dr_efs" {
  name = "DR_EFS"
}
data "aws_ssm_parameter" "dr_efs_data" {
  name = "DR_EFS_DATA"
}
data "aws_ssm_parameter" "dr_task" {
  name = "DR_TASK"
}
data "aws_ssm_parameter" "ii_host" {
  name = "II_HOST"
}
data "aws_ssm_parameter" "ii_host_cn" {
  name = "II_HOST_CN"
}
data "aws_ssm_parameter" "ii_efs" {
  name = "II_EFS"
}
data "aws_ssm_parameter" "pa_host" {
  name = "PA_HOST"
}
data "aws_ssm_parameter" "pa_host_cn" {
  name = "PA_HOST_CN"
}
data "aws_ssm_parameter" "pa_efs" {
  name = "PA_EFS"
}
data "aws_ssm_parameter" "resolver" {
  name = "RESOLVER"
}
data "aws_ssm_parameter" "ssl" {
  name = "SSL"
}
data "aws_ssm_parameter" "htaccess" {
  name = "HTACCESS"
}
data "aws_ssm_parameter" "dr_dm_pass" {
  name = "DR_DM_PASS"
}
data "aws_ssm_parameter" "dr_user_pass" {
  name = "DR_USER_PASS"
}
data "aws_ssm_parameter" "ht_user" {
  name = "HT_USER"
}
data "aws_ssm_parameter" "ht_dm_user" {
  name = "HT_DM_USER"
}
data "aws_ssm_parameter" "mongo_pass" {
  name = "MONGO_INITDB_ROOT_PASSWORD"
}
data "aws_ssm_parameter" "mongo_user" {
  name = "MONGO_INITDB_ROOT_USERNAME"
}
