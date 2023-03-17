resource "aws_iam_role" "lambda_function_iam" {
  name = var.function_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.function_name}-extra"
  role   = aws_iam_role.lambda_function_iam.id
  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ssm:GetParameter"
        ],
        "Resource": [
          ${aws_ssm_parameter.thumbnail_private_key.arn}
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:GetItem"
        ],
        "Resource": [
          "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.datasets_table_name}"
        ]
      }
    ]
  }
  EOF
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<-EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "1",
        "Effect": "Allow",
        "Principal": {
          "AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
        },
        "Action": "s3:GetObject",
        "Resource": "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  }
  EOF
}

