output "cloudfront_domain_name" {
  description = "Default CloudFront distribution domain name"

  value = var.cloudfront_enabled ? aws_cloudfront_distribution.app[0].domain_name : null
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"

  value = var.cloudfront_enabled ? aws_cloudfront_distribution.app[0].id : null
}

output "application_url" {
  description = "CloudFront default application URL"

  value = var.cloudfront_enabled ? "https://${aws_cloudfront_distribution.app[0].domain_name}" : null
}
