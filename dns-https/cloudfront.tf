# ---------------------------------------------------------
# Remote state: Application
# ---------------------------------------------------------

data "terraform_remote_state" "application_cloudfront" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "03-application/terraform.tfstate"
    region = var.aws_region
  }
}


# ---------------------------------------------------------
# CloudFront Distribution
# ---------------------------------------------------------

resource "aws_cloudfront_distribution" "app" {
  count = var.cloudfront_enabled ? 1 : 0

  enabled = true

  comment = "${var.project_name}-${var.environment} application distribution"

  aliases = [
    "${var.application_subdomain}.${var.domain_name}"
  ]


  # -------------------------------------------------------
  # ALB Origin
  # -------------------------------------------------------

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


  # -------------------------------------------------------
  # Default Cache Behavior
  # -------------------------------------------------------

  default_cache_behavior {
    target_origin_id = "${var.project_name}-${var.environment}-alb"

    viewer_protocol_policy = "redirect-to-https"

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


  # -------------------------------------------------------
  # Viewer Certificate
  # -------------------------------------------------------

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cloudfront.certificate_arn

    ssl_support_method = "sni-only"

    minimum_protocol_version = "TLSv1.2_2021"
  }


  # -------------------------------------------------------
  # IPv6
  # -------------------------------------------------------

  is_ipv6_enabled = true


  # -------------------------------------------------------
  # Price Class
  # -------------------------------------------------------

  price_class = "PriceClass_100"


  # -------------------------------------------------------
  # Restrictions
  # -------------------------------------------------------

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  tags = {
    Name = "${var.project_name}-${var.environment}-cloudfront"
  }
}
