# ---------------------------------------------------------
# ALB Outputs
# ---------------------------------------------------------

output "alb_id" {
  description = "Application Load Balancer ID."
  value       = aws_lb.app.id
}

output "alb_arn" {
  description = "Application Load Balancer ARN."
  value       = aws_lb.app.arn
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix used by CloudWatch."
  value       = aws_lb.app.arn_suffix
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name."
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID used by Route 53."
  value       = aws_lb.app.zone_id
}

# ---------------------------------------------------------
# Target Group Outputs
# ---------------------------------------------------------

output "target_group_arn" {
  description = "Application target group ARN."
  value       = aws_lb_target_group.app.arn
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix used by CloudWatch."
  value       = aws_lb_target_group.app.arn_suffix
}

output "target_group_name" {
  description = "Application target group name."
  value       = aws_lb_target_group.app.name
}

# ---------------------------------------------------------
# Auto Scaling Outputs
# ---------------------------------------------------------

output "autoscaling_group_name" {
  description = "Application Auto Scaling Group name."
  value       = try(aws_autoscaling_group.app[0].name, null)
}

output "autoscaling_min_size" {
  description = "Minimum number of application instances."
  value       = var.min_size
}

output "autoscaling_desired_capacity" {
  description = "Desired number of application instances."
  value       = var.desired_capacity
}

output "autoscaling_max_size" {
  description = "Maximum number of application instances."
  value       = var.max_size
}

# ---------------------------------------------------------
# Launch Template Outputs
# ---------------------------------------------------------

output "launch_template_id" {
  description = "Application EC2 launch template ID."
  value       = aws_launch_template.app.id
}

# ---------------------------------------------------------
# IAM Outputs
# ---------------------------------------------------------

output "app_iam_role_arn" {
  description = "IAM role ARN used by application EC2 instances."
  value       = aws_iam_role.app.arn
}

output "app_instance_profile_name" {
  description = "EC2 instance profile used by application instances."
  value       = aws_iam_instance_profile.app.name
}

# ---------------------------------------------------------
# ECR Outputs
# ---------------------------------------------------------

output "ecr_repository_url" {
  description = "Amazon ECR repository URL."
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "Amazon ECR repository ARN."
  value       = aws_ecr_repository.app.arn
}

# ---------------------------------------------------------
# Logging Outputs
# ---------------------------------------------------------

output "application_log_group_name" {
  description = "CloudWatch log group used by application containers."
  value       = aws_cloudwatch_log_group.application.name
}
