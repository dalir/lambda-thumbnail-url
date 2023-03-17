# Accounts
variable "environment" {}
variable "account_id" {}
variable "region" {}
variable "provider_bucket" {}
variable "provider_role" {}

# Versioning
variable "repo_organization" {}
variable "repo_full_name" {}
variable "git_sha" {}

# Lambda Configurations
variable "function_name" {}
variable "lambda_package" {}

# Other
variable "cloudwatch_logs_retention_days" {}
variable "debug" {
  default = "@skycatch/*"
}

variable "publish" {
  default = false
}

variable "datadog_log_forwarder_name" {
  default = ""
}

# Application Variables
variable "aws_cloudfront_cache_duration_sec" {
  default = 3600
}

variable "bucket_name" {}
