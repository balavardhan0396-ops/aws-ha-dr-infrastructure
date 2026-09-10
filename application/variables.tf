variable "aws_region" {
  description = "AWS region where the application will be deployed."
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

variable "app_port" {
  description = "Port on which the Node.js application listens."
  type        = number
  default     = 3001
}

variable "instance_type" {
  description = "EC2 instance type for application servers."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Amazon Linux 2023 AMI ID."
  type        = string
}

variable "min_size" {
  description = "Minimum number of application instances."
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of application instances."
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of application instances."
  type        = number
  default     = 4
}

variable "health_check_path" {
  description = "HTTP health check path for the application."
  type        = string
  default     = "/"
}

variable "app_image" {
  description = "Docker image used by the application."
  type        = string
  default     = "three-tire-app:latest"
}
