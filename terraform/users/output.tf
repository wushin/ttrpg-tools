output "ttrpg_access_key_id" {
  value       = aws_iam_access_key.ttrpg.id
  description = "Access Key ID for deployment"
}

output "ttrpg_access_key_secret" {
  value       = aws_iam_access_key.ttrpg.secret
  description = "Access Key Secret for deployment"
}

output "ttrpg_password" {
  value = aws_iam_user_login_profile.ttrpg.encrypted_password
}

output "ttrpg_s3_access_key_id" {
  value       = aws_iam_access_key.ttrpg-s3.id
  description = "Access Key ID for backup"
}

output "ttrpg_s3_access_key_secret" {
  value       = aws_iam_access_key.ttrpg-s3.secret
  description = "Access Key Secret for backup"
}
