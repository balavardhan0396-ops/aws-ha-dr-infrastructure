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

variable "cloudfront_enabled" {
  description = "Whether CloudFront should be created"
  type        = bool
  default     = true
}
