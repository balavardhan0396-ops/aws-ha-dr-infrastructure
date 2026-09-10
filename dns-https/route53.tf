# ---------------------------------------------------------
# Remote state: Application
# ---------------------------------------------------------
# Get the existing ALB information from Phase 3.
# No ALB IDs or DNS names are hardcoded here.

data "terraform_remote_state" "application" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "03-application/terraform.tfstate"
    region = var.aws_region
  }
}


# ---------------------------------------------------------
# Route 53 Hosted Zone
# ---------------------------------------------------------
# This creates the public hosted zone for the domain.
#
# Example:
#   yourdomain.com
#
# Route 53 will provide name servers after creation.
# These name servers must be configured at your domain
# registrar if the domain is currently using another DNS
# provider.

resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "${var.project_name}-${var.environment}-hosted-zone"
  }
}


# ---------------------------------------------------------
# Application DNS Record
# ---------------------------------------------------------
# Example:
#
#   app.yourdomain.com
#
# When CloudFront is enabled:
#
#   User
#     ↓
#   app.yourdomain.com
#     ↓
#   CloudFront
#     ↓
#   ALB
#
# When CloudFront is disabled:
#
#   User
#     ↓
#   app.yourdomain.com
#     ↓
#   ALB

resource "aws_route53_record" "application" {
  zone_id = aws_route53_zone.main.zone_id

  name = "${var.application_subdomain}.${var.domain_name}"

  type = "A"

  alias {
    name = var.cloudfront_enabled ? aws_cloudfront_distribution.app[0].domain_name : data.terraform_remote_state.application.outputs.alb_dns_name

    zone_id = var.cloudfront_enabled ? aws_cloudfront_distribution.app[0].hosted_zone_id : data.terraform_remote_state.application.outputs.alb_zone_id

    evaluate_target_health = false
  }
}
