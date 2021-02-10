provider "aws" {
  region  = var.aws_region
  profile = "ttrpg-root"
}

resource "aws_iam_group" "deploy" {
  name = "deploy"
}

resource "aws_iam_group_policy_attachment" "ec2" {
  group      = aws_iam_group.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "s3" {
  group      = aws_iam_group.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_group_policy_attachment" "cloudwatch" {
  group      = aws_iam_group.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_group_policy_attachment" "dynamoDB" {
  group      = aws_iam_group.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_group_policy_attachment" "cloudfront" {
  group      = aws_iam_group.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
}

resource "aws_iam_group_policy_attachment" "route53" {
  group      = aws_iam_group.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_group_policy_attachment" "acm" {
  group      = aws_iam_group.deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCertificateManagerFullAccess"
}

resource "aws_iam_user" "ttrpg" {
  name = "ttrpg"
}

resource "aws_iam_group_membership" "deploy" {
  name = "ttrpg-deploy"
  users = [
    aws_iam_user.ttrpg.name,
  ]
  group = aws_iam_group.deploy.name
}

resource "aws_iam_access_key" "ttrpg" {
  user = aws_iam_user.ttrpg.name
}

resource "aws_iam_user_login_profile" "ttrpg" {
  user = aws_iam_user.ttrpg.name
  pgp_key = filebase64("z.gpg.pub")
  password_reset_required = false
}

resource "aws_iam_group" "ttrpg-s3-only" {
  name = "ttrpg-s3-only"
}

resource "aws_iam_group_policy_attachment" "ttrpg-s3-only" {
  group      = aws_iam_group.ttrpg-s3-only.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_user" "ttrpg-s3" {
  name = "ttrpg-s3"
}

resource "aws_iam_group_membership" "ttrpg-s3" {
  name = "ttrpg-s3"
  users = [
    aws_iam_user.ttrpg-s3.name,
  ]
  group = aws_iam_group.ttrpg-s3-only.name
}

resource "aws_iam_access_key" "ttrpg-s3" {
  user = aws_iam_user.ttrpg-s3.name
}
