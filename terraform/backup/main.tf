terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

resource "aws_s3_bucket" "ttrpg_bucket" {
  bucket = "ttrpg-terraform-bucket"
  acl    = "private"
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
}

resource "aws_s3_bucket_object" "mongo_data" {
  bucket = aws_s3_bucket.ttrpg_bucket.id
  acl    = "private"
  key    = "mongo_data/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "dr_data" {
  bucket = aws_s3_bucket.ttrpg_bucket.id
  acl    = "private"
  key    = "dr_data/"
  source = "/dev/null"
}
