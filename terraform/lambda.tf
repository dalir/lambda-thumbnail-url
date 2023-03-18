data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../main"
  output_path = var.lambda_package
}

resource "aws_lambda_function" "thumbnail-url" {
  description = "Commit: ${var.git_sha} @ https://github.com/${var.repo_full_name}"
  filename = var.lambda_package
  function_name = var.function_name
  publish = var.publish
  handler = "main"
  runtime = "go1.x"
  role = aws_iam_role.lambda_function_iam.arn
  timeout = "60"
  memory_size = 128
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      REGION                    = var.region
      AWS_CF_URL                = "https://${aws_cloudfront_distribution.bucket.domain_name}"
      AWS_CF_KEY_ID             = aws_cloudfront_public_key.thumbnail.id
      AWS_SSM_PARAM             = aws_ssm_parameter.thumbnail_private_key.name
    }
  }
}

resource "aws_cloudwatch_log_group" "thumbnail-copier" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 14
}
