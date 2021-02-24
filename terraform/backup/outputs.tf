output "s3_bucket_domain_name" {
    value = aws_s3_bucket.ttrpg_bucket.bucket_domain_name
}
output "s3_bucket" {
    value = aws_s3_bucket.ttrpg_bucket.bucket
}
output "s3_bucket_dr_task" {
    value = aws_datasync_location_s3.dr_data.arn
}
