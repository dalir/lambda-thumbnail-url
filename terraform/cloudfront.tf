resource "tls_private_key" "thumbnail" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_cloudfront_public_key" "thumbnail" {
  comment     = "thumbnail public key"
  encoded_key = tls_private_key.thumbnail.public_key_pem
  name        = "thumbnail-public-key"
}

resource "aws_cloudfront_key_group" "thumbnail" {
  comment = "thumbnail key group"
  items   = [aws_cloudfront_public_key.thumbnail.id]
  name    = "thumbnail-key-group"
}

resource "aws_ssm_parameter" "thumbnail_private_key" {
  name      = "/datasets/ssh_private_key"
  type      = "SecureString"
  value     = tls_private_key.thumbnail.private_key_pem
  overwrite = true
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access Identity for s3.${var.bucket_name}: Managed by Terraform"
}

resource "aws_cloudfront_distribution" "bucket" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_domain_name
    origin_id = "S3-${aws_s3_bucket.bucket.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled = true
  price_class = "PriceClass_All"
  is_ipv6_enabled = true
  comment = "s3.${var.bucket_name}: Managed by Terraform"

  default_cache_behavior {
    target_origin_id = "S3-${aws_s3_bucket.bucket.id}"
    trusted_key_groups = [aws_cloudfront_key_group.thumbnail.id]
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0

    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    default_ttl = 86400
    max_ttl = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version = "TLSv1"
  }
}
