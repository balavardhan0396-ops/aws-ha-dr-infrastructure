data "terraform_remote_state" "application_cloudfront" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "application/terraform.tfstate"
    region = var.aws_region
  }
}

resource "aws_cloudfront_distribution" "app" {
  count = var.cloudfront_enabled ? 1 : 0

  enabled = true

  comment = "${var.project_name}-${var.environment} application distribution"

  origin {
    domain_name = data.terraform_remote_state.application_cloudfront.outputs.alb_dns_name

    origin_id = "${var.project_name}-${var.environment}-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"

      origin_ssl_protocols = [
        "TLSv1.2"
      ]
    }
  }

  default_cache_behavior {
    target_origin_id = "${var.project_name}-${var.environment}-alb"

    # Do not force HTTPS for this assignment
    viewer_protocol_policy = "allow-all"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    compress = true

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  # Use the default CloudFront certificate.
  # No custom domain or ACM certificate is required.
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  is_ipv6_enabled = true

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cloudfront"
  }
}
