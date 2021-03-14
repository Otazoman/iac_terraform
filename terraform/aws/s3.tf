data "aws_iam_policy_document" "cloudfront-logging-bucket" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      identifiers = ["*"]
      type        = "*"
    }
    actions = [
      "s3:ListBucket",
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}-cloudfront-logs",
      "arn:aws:s3:::${var.bucket_name}-cloudfront-logs/*"
    ]
  }
}

resource "aws_s3_bucket" "cloudfront-logging" {
  bucket        = "${var.bucket_name}-cloudfront-logs"
  policy        = data.aws_iam_policy_document.cloudfront-logging-bucket.json
  request_payer = "BucketOwner"
}

resource "aws_s3_bucket_public_access_block" "cloudfront-logging" {
  bucket                  = aws_s3_bucket.cloudfront-logging.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "website-logs" {
  bucket = "${var.bucket_name}-logs"
  acl    = "log-delivery-write"
  tags = {
    ManagedBy = "terraform"
    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_s3_bucket" "static-site" {
  bucket = var.bucket_name
  acl    = "private"
  policy = data.aws_iam_policy_document.static-site-bucket_policy.json
  versioning {
    enabled = true
  }
  logging {
    target_bucket = aws_s3_bucket.website-logs.bucket
    target_prefix = "${var.bucket_name}/"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  s3-origin-id-static-site = "s3-origin-id-static-site"
}

data "aws_iam_policy_document" "static-site-bucket_policy" {
  statement {
    sid    = ""
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.static-site-idntity.iam_arn}"]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}