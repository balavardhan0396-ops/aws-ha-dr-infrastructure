variable "aws_region" {
  description = "Primary AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "aws-ha-dr"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "lab"
}

variable "domain_name" {
  description = "Root domain name managed through Route 53"
  type        = string
}

variable "application_subdomain" {
  description = "Subdomain used to access the application"
  type        = string
  default     = "app"
}

variable "cloudfront_enabled" {
  description = "Whether CloudFront should be created"
  type        = bool
  default     = true
}
