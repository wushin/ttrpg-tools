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
}

resource "aws_s3_bucket_object" "letsencrypt_objects" {
  for_each = var.restore_from_local ? fileset("${var.module_depth}nginx/ssl/", "**") : []
  bucket = aws_s3_bucket.ttrpg_bucket.id
  key = "letsencrypt/${each.value}"
  source = "${var.module_depth}nginx/ssl/${each.value}"
}

resource "aws_s3_bucket_object" "mongo_data" {
  bucket = aws_s3_bucket.ttrpg_bucket.id
  acl    = "private"
  key    = "mongo_data/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "mongo_data_objects" {
  for_each = var.restore_from_local ? fileset("${var.module_depth}mongo/data/", "**") : []
  bucket = aws_s3_bucket.ttrpg_bucket.id
  key = "mongo_data/${each.value}"
  source = "${var.module_depth}mongo/data/${each.value}"
}

resource "aws_s3_bucket_object" "dr_data" {
  bucket = aws_s3_bucket.ttrpg_bucket.id
  acl    = "private"
  key    = "dr_data/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "dr_data_objects" {
  for_each = var.restore_from_local ? fileset("${var.module_depth}dungeon-revealer/data/", "**") : []
  bucket = aws_s3_bucket.ttrpg_bucket.id
  key = "dr_data/${each.value}"
  source = "${var.module_depth}dungeon-revealer/data/${each.value}"
}

