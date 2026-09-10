# ---------------------------------------------------------
# Remote state: Database
# ---------------------------------------------------------

data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "02-database/terraform.tfstate"
    region = var.aws_region
  }
}


# ---------------------------------------------------------
# Remote state: Application
# ---------------------------------------------------------

data "terraform_remote_state" "application" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "03-application/terraform.tfstate"
    region = var.aws_region
  }
}


# =========================================================
# APPLICATION / EC2 MONITORING
# =========================================================

resource "aws_cloudwatch_metric_alarm" "app_high_cpu" {
  alarm_name = "${var.project_name}-${var.environment}-app-high-cpu"

  alarm_description = "Application EC2 instances have high CPU utilization"

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = data.terraform_remote_state.application.outputs.autoscaling_group_name
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "${var.project_name}-app-high-cpu"
  }
}


# =========================================================
# APPLICATION LOAD BALANCER MONITORING
# =========================================================

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name = "${var.project_name}-${var.environment}-alb-5xx"

  alarm_description = "Application Load Balancer is returning HTTP 5XX errors"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"

  dimensions = {
    LoadBalancer = data.terraform_remote_state.application.outputs.alb_arn_suffix
  }

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "${var.project_name}-alb-5xx"
  }
}


resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name = "${var.project_name}-${var.environment}-alb-unhealthy-hosts"

  alarm_description = "Application Load Balancer has unhealthy application instances"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = data.terraform_remote_state.application.outputs.alb_arn_suffix
    TargetGroup  = data.terraform_remote_state.application.outputs.target_group_arn_suffix
  }

  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "${var.project_name}-alb-unhealthy-hosts"
  }
}


# =========================================================
# RDS MONITORING
# =========================================================

resource "aws_cloudwatch_metric_alarm" "rds_high_cpu" {
  alarm_name = "${var.project_name}-${var.environment}-rds-high-cpu"

  alarm_description = "RDS CPU utilization is high"

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"

  dimensions = {
    DBInstanceIdentifier = data.terraform_remote_state.database.outputs.rds_instance_id
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "${var.project_name}-rds-high-cpu"
  }
}


resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name = "${var.project_name}-${var.environment}-rds-low-storage"

  alarm_description = "RDS free storage space is low"

  namespace   = "AWS/RDS"
  metric_name = "FreeStorageSpace"

  dimensions = {
    DBInstanceIdentifier = data.terraform_remote_state.database.outputs.rds_instance_id
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2

  # 2 GB in bytes
  threshold = 2147483648

  comparison_operator = "LessThanThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "${var.project_name}-rds-low-storage"
  }
}


resource "aws_cloudwatch_metric_alarm" "rds_high_connections" {
  alarm_name = "${var.project_name}-${var.environment}-rds-high-connections"

  alarm_description = "RDS database connection count is high"

  namespace   = "AWS/RDS"
  metric_name = "DatabaseConnections"

  dimensions = {
    DBInstanceIdentifier = data.terraform_remote_state.database.outputs.rds_instance_id
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "${var.project_name}-rds-high-connections"
  }
}
