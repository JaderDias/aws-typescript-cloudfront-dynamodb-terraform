resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.deployment_id}-site"

  tags = var.additional_tags
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}