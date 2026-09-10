output "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "route53_name_servers" {
  description = "Name servers for the Route 53 hosted zone"
  value       = aws_route53_zone.main.name_servers
}

output "application_domain_name" {
  description = "Application domain name"
  value       = "${var.application_subdomain}.${var.domain_name}"
}

output "alb_certificate_arn" {
  description = "ACM certificate ARN for the Application Load Balancer"
  value       = aws_acm_certificate.alb.arn
}

output "cloudfront_certificate_arn" {
  description = "ACM certificate ARN for CloudFront"
  value       = aws_acm_certificate.cloudfront.arn
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = var.cloudfront_enabled ? aws_cloudfront_distribution.app[0].domain_name : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.cloudfront_enabled ? aws_cloudfront_distribution.app[0].id : null
}

output "application_url" {
  description = "HTTPS URL for the application"
  value       = "https://${var.application_subdomain}.${var.domain_name}"
}
