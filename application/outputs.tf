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

output "alb_dns_name" {
  description = "Application Load Balancer DNS name."
  value       = aws_lb.app.dns_name
}


# ---------------------------------------------------------
# Target Group Outputs
# ---------------------------------------------------------

output "target_group_arn" {
  description = "Application target group ARN."
  value       = aws_lb_target_group.app.arn
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
  value       = aws_autoscaling_group.app.name
}

output "autoscaling_min_size" {
  description = "Minimum number of application instances."
  value       = aws_autoscaling_group.app.min_size
}

output "autoscaling_desired_capacity" {
  description = "Desired number of application instances."
  value       = aws_autoscaling_group.app.desired_capacity
}

output "autoscaling_max_size" {
  description = "Maximum number of application instances."
  value       = aws_autoscaling_group.app.max_size
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
