data "aws_iam_policy_document" "web_application" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.web_application.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_s3_bucket" "web_application" {
  bucket = var.domain
}

resource "aws_s3_bucket_policy" "web_application" {
  bucket = aws_s3_bucket.web_application.id
  policy = data.aws_iam_policy_document.web_application.json
}

resource "aws_s3_bucket_website_configuration" "web_application" {
  bucket = aws_s3_bucket.web_application.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "web_application" {
  bucket = aws_s3_bucket.web_application.id

  versioning_configuration {
    status = "Enabled"
  }
}