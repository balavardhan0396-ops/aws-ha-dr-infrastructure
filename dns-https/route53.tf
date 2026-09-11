# ---------------------------------------------------------
# Remote state: Application
# ---------------------------------------------------------

data "terraform_remote_state" "application" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "application/terraform.tfstate"
    region = var.aws_region
  }
}

# ---------------------------------------------------------
# Route 53 Hosted Zone
# ---------------------------------------------------------

resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "${var.project_name}-${var.environment}-hosted-zone"
  }
}

# ---------------------------------------------------------
# Application DNS Record
# ---------------------------------------------------------

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
