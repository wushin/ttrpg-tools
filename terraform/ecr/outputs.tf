output "nginx_repo_url" {
  value = aws_ecr_repository.ttrpg-nginx.repository_url
}
output "dr_repo_url" {
  value = aws_ecr_repository.ttrpg-dr.repository_url
}
output "ii_repo_url" {
  value = aws_ecr_repository.ttrpg-ii.repository_url
}
output "pa_repo_url" {
  value = aws_ecr_repository.ttrpg-pa.repository_url
}
