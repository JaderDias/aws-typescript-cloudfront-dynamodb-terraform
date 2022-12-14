module "s3website" {
  source               = "./modules/s3website"
  deployment_id        = var.deployment_id
  additional_tags      = var.additional_tags
  s3_canonical_user_id = aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id
}

resource "aws_s3_object" "static_object" {
  for_each = {
    "bulma.min.css" = "text/css"
    "index.html"    = "text/html"
    "robots.txt"    = "text/plain"
  }
  bucket       = module.s3website.id
  content_type = each.value
  etag         = filemd5("../static/${each.key}")
  key          = basename("../static/${each.key}")
  source       = "../static/${each.key}"
}