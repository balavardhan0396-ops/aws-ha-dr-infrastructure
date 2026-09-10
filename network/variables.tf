variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Name of the project."
  type        = string
  default     = "aws-ha-dr"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones used by the infrastructure."
  type        = list(string)

  default = [
    "eu-north-1a",
    "eu-north-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets."
  type        = list(string)

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets."
  type        = list(string)

  default = [
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]
}

variable "app_port" {
  description = "Port used by the application."
  type        = number
  default     = 3001
}
