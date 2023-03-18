variable "account_id" {
  description = "AWS account ID"
}

variable "region" {
  description = "AWS region to host your network"
  default = "us-west-2"
}

variable "lambda_package" {
  default = "../deployment/package.zip"
}

variable "environment" {}
variable "repo_organization" {}
variable "repo_name" {}
variable "repo_full_name" {}
variable "git_sha" {}

variable "provider_role" {}
variable "provider_bucket" {}
variable "function_name" {}

variable "publish" {
  default = false
}

variable "bucket_name" {}
