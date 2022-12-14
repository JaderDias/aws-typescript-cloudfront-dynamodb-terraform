resource "aws_dynamodb_table" "site_table" {
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "hash"
  name             = "${var.deployment_id}-table"
  range_key        = "range"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
  table_class      = "STANDARD"

  attribute {
    name = "hash"
    type = "S"
  }

  attribute {
    name = "range"
    type = "S"
  }

  tags = var.additional_tags
}
