# ---------------------------------------------------------
# Auto Scaling Group
# ---------------------------------------------------------

resource "aws_autoscaling_group" "app" {
  count = var.enable_asg ? 1 : 0

  name = "${var.project_name}-${var.environment}-asg"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier = data.terraform_remote_state.network.outputs.app_subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = 120

  target_group_arns = [
    aws_lb_target_group.app.arn
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "Application"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------
# Target Tracking Scaling Policy
# ---------------------------------------------------------

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  count = var.enable_asg ? 1 : 0

  name                   = "${var.project_name}-${var.environment}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.app[0].name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50
  }
}
