variable "aws_region" {
  description = "AWS region where the RDS database will be deployed."
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

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Master username for the RDS database."
  type        = string
  default     = "appadmin"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_engine_version" {
  description = "MySQL engine version."
  type        = string
  default     = "8.0"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB."
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum storage for autoscaling in GB."
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Daily automated backup window."
  type        = string
  default     = "01:00-01:30"
}

variable "maintenance_window" {
  description = "Weekly maintenance window."
  type        = string
  default     = "sun:02:00-sun:02:30"
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot when destroying the database."
  type        = bool
  default     = true
}
