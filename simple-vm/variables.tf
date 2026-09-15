variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "app_port" {
  type    = number
  default = 3000
}
