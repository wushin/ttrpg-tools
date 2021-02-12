terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_iam_role" "s3_access" {
  name = "AWSDataSyncS3BucketAccess-ttrpg-terraform-bucket"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "datasync.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_access" {
  name = "AWSDataSyncS3BucketAccess-ttrpg-terraform-bucket"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::ttrpg-terraform-bucket"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:ListMultipartUploadParts",
                "s3:PutObjectTagging",
                "s3:GetObjectTagging",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::ttrpg-terraform-bucket/*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.s3_access.name
  policy_arn = aws_iam_policy.s3_access.arn
}

resource "aws_s3_bucket" "ttrpg_bucket" {
  bucket = "ttrpg-terraform-bucket"
  acl    = "private"
  force_destroy = true
  versioning {
    enabled = true
  }

  tags = {
    Name = "ttrpg-terraform-bucket"
  }
}

resource "aws_s3_bucket_object" "letsencrypt" {
  bucket = aws_s3_bucket.ttrpg_bucket.id
  acl    = "private"
  key    = "letsencrypt/"
  source = "/dev/null"

  provisioner "local-exec" {
    when    = create
    command = var.restore_from_local ? "aws --profile ttrpg s3 sync ${var.module_depth}nginx/ssl/ s3://ttrpg-terraform-bucket/letsencrypt/" : "echo no restore"
  }
}

resource "aws_s3_bucket_object" "dr_data" {
  bucket = aws_s3_bucket.ttrpg_bucket.id
  acl    = "private"
  key    = "dr_data/"
  source = "/dev/null"

  provisioner "local-exec" {
    when    = create
    command = var.restore_from_local ? "aws --profile ttrpg s3 sync ${var.module_depth}dungeon-revealer/data/ s3://ttrpg-terraform-bucket/dr_data/" : "echo no restore"
  }
}

resource "aws_datasync_location_s3" "dr_data" {
  s3_bucket_arn = aws_s3_bucket.ttrpg_bucket.arn
  subdirectory  = "/dr_data"

  s3_config {
    bucket_access_role_arn = aws_iam_role.s3_access.arn
  }
}

resource "aws_datasync_location_s3" "letsencrypt" {
  s3_bucket_arn = aws_s3_bucket.ttrpg_bucket.arn
  subdirectory  = "/letsencrypt"

  s3_config {
    bucket_access_role_arn = aws_iam_role.s3_access.arn
  }
}
