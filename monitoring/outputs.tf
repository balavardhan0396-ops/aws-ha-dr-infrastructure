output "sns_topic_arn" {
  description = "SNS topic ARN used for monitoring notifications"
  value       = aws_sns_topic.alerts.arn
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = aws_sns_topic.alerts.name
}

output "application_log_group_name" {
  description = "CloudWatch log group for application logs"
  value       = aws_cloudwatch_log_group.application.name
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "cloudwatch_dashboard_arn" {
  description = "CloudWatch dashboard ARN"
  value       = aws_cloudwatch_dashboard.main.dashboard_arn
}

output "app_high_cpu_alarm_name" {
  description = "Application high CPU alarm"
  value       = aws_cloudwatch_metric_alarm.app_high_cpu.alarm_name
}

output "alb_5xx_alarm_name" {
  description = "ALB 5XX alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
}

output "alb_unhealthy_hosts_alarm_name" {
  description = "ALB unhealthy hosts alarm"
  value       = aws_cloudwatch_metric_alarm.alb_unhealthy_hosts.alarm_name
}

output "rds_high_cpu_alarm_name" {
  description = "RDS high CPU alarm"
  value       = aws_cloudwatch_metric_alarm.rds_high_cpu.alarm_name
}

output "rds_low_storage_alarm_name" {
  description = "RDS low storage alarm"
  value       = aws_cloudwatch_metric_alarm.rds_low_storage.alarm_name
}

output "rds_high_connections_alarm_name" {
  description = "RDS high database connections alarm"
  value       = aws_cloudwatch_metric_alarm.rds_high_connections.alarm_name
}
