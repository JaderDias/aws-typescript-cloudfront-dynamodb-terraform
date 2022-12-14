data "aws_iam_policy_document" "cloudfront_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    principals {
      type        = "CanonicalUser"
      identifiers = [var.s3_canonical_user_id]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.cloudfront_bucket_policy.json
}