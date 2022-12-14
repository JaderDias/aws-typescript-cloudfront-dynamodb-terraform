resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = var.deployment_id
}

data "aws_cloudfront_cache_policy" "caching_optimized_cache_policy" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "cors_s3_origin_request_policy" {
  name = "Managed-CORS-S3Origin"
}

resource "aws_cloudfront_response_headers_policy" "response_headers_policy" {
  name = "${var.deployment_id}-response_headers_policy"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      override                   = true
      preload                    = true
    }

    /* HTTP security headers only relevant if the site contains user generated content */
    content_security_policy {
      content_security_policy = "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'"
      override                = true
    }
    content_type_options {
      override = true
    }
    xss_protection {
      mode_block = true
      protection = true
      override   = true
    }

    /* HTTP security headers only relevant if there are authenticated users in the site */
    frame_options {
      frame_option = "DENY"
      override     = true
    }
  }

  custom_headers_config {
    items {
      header   = "cache-control"
      value    = "public, max-age=63072000;"
      override = false
    }
  }
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = "${var.deployment_id}-logs"

  tags = var.additional_tags
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = module.s3website.bucket_regional_domain_name
    origin_id   = module.s3website.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  http_version        = "http3"
  comment             = "${var.deployment_id}-multi-region-site"
  default_root_object = "index.html"

  logging_config {
    include_cookies = true
    bucket          = aws_s3_bucket.logs_bucket.bucket_domain_name
    prefix          = "cloudfront"
  }

  default_cache_behavior {
    allowed_methods            = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized_cache_policy.id
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    compress                   = true
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.cors_s3_origin_request_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.response_headers_policy.id
    target_origin_id           = module.s3website.id
    viewer_protocol_policy     = "redirect-to-https"

    lambda_function_association {
      event_type   = "viewer-request"
      lambda_arn   = module.lambda-at-edge-viewer-request.arn
      include_body = true
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = var.additional_tags

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}