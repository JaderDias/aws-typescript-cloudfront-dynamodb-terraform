variable "additional_tags" {
  default = {
    application = "typescript-at-edge"
    environment = "dev"
  }
  description = "Additional resource tags"
  type        = map(string)
}

variable "aws_region" {
  type = string
}

variable "deployment_id" {
  type    = string
  default = "dev-typescript-at-edge"
}