output "rds_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.main.id
}

output "rds_instance_arn" {
  description = "RDS instance ARN."
  value       = aws_db_instance.main.arn
}

output "rds_endpoint" {
  description = "RDS endpoint."
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS hostname."
  value       = aws_db_instance.main.address
}

output "rds_port" {
  description = "RDS port."
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "Initial database name."
  value       = var.db_name
}

output "rds_subnet_group_name" {
  description = "RDS subnet group name."
  value       = aws_db_subnet_group.main.name
}

output "db_security_group_id" {
  description = "Database security group ID obtained from the network state."
  value       = data.terraform_remote_state.network.outputs.db_security_group_id
}

output "db_secret_arn" {
  description = "ARN of the database credentials secret."
  value       = aws_secretsmanager_secret.db.arn
}
