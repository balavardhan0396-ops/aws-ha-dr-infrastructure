# ---------------------------------------------------------
# ACM Certificate for ALB
# Region: eu-north-1
# ---------------------------------------------------------

resource "aws_acm_certificate" "alb" {
  domain_name = "${var.application_subdomain}.${var.domain_name}"

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-certificate"
  }
}


# ---------------------------------------------------------
# ACM DNS Validation Record for ALB
# ---------------------------------------------------------

resource "aws_route53_record" "alb_certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.alb.domain_validation_options :
    option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  }

  zone_id = aws_route53_zone.main.zone_id

  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  allow_overwrite = true
}


# ---------------------------------------------------------
# Validate ALB Certificate
# ---------------------------------------------------------

resource "aws_acm_certificate_validation" "alb" {
  certificate_arn = aws_acm_certificate.alb.arn

  validation_record_fqdns = [
    for record in aws_route53_record.alb_certificate_validation :
    record.fqdn
  ]
}


# ---------------------------------------------------------
# ACM Certificate for CloudFront
# Region: us-east-1
# ---------------------------------------------------------

resource "aws_acm_certificate" "cloudfront" {
  provider = aws.us_east_1

  domain_name = "${var.application_subdomain}.${var.domain_name}"

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-cloudfront-certificate"
  }
}


# ---------------------------------------------------------
# ACM DNS Validation Record for CloudFront
# ---------------------------------------------------------

resource "aws_route53_record" "cloudfront_certificate_validation" {
  for_each = {
    for option in aws_acm_certificate.cloudfront.domain_validation_options :
    option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type
    }
  }

  zone_id = aws_route53_zone.main.zone_id

  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]

  allow_overwrite = true
}


# ---------------------------------------------------------
# Validate CloudFront Certificate
# ---------------------------------------------------------

resource "aws_acm_certificate_validation" "cloudfront" {
  provider = aws.us_east_1

  certificate_arn = aws_acm_certificate.cloudfront.arn

  validation_record_fqdns = [
    for record in aws_route53_record.cloudfront_certificate_validation :
    record.fqdn
  ]
}
