provider "aws" {
  alias  = "lambda-at-edge-region"
  region = "us-east-1"
}

module "lambda-at-edge-viewer-request" {
  providers = {
    aws = aws.lambda-at-edge-region
  }

  description            = "Typescript Viewer-Request"
  file_globs             = ["index.js"]
  lambda_code_source_dir = "${path.module}/../typescript/lambda-at-edge/viewer-request"
  name                   = "${var.deployment_id}-viewer-request"
  runtime                = "nodejs18.x"
  source                 = "JaderDias/lambda-at-edge/aws"
  version                = "0.5.2"
  plaintext_params = {
    dynamodb_table_name = aws_dynamodb_table.site_table.name
  }
}

data "aws_iam_policy_document" "lambda_exec_role_policy" {
  statement {
    actions = [
      "dynamodb:*",
    ]
    resources = [
      "arn:aws:dynamodb:*"
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "${module.lambda-at-edge-viewer-request.function_name}-lambda-policy"
  description = "${module.lambda-at-edge-viewer-request.function_name}-lambda-policy"
  policy      = data.aws_iam_policy_document.lambda_exec_role_policy.json
  tags        = var.additional_tags
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_iam_policy_basic_execution" {
  role       = module.lambda-at-edge-viewer-request.execution_role_name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
