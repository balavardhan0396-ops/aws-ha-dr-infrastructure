variable "aws_region" {
  description = "AWS region"
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
