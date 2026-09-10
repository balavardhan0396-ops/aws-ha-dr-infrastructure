# ---------------------------------------------------------
# Remote state: Network
# ---------------------------------------------------------

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "01-network/terraform.tfstate"
    region = var.aws_region
  }
}


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


# ---------------------------------------------------------
# CloudWatch Log Group
# ---------------------------------------------------------
# Application logs can be sent to this log group by the
# application EC2 instances / CloudWatch Agent.

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/${var.project_name}/${var.environment}/application"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-application-logs"
  }
}


# ---------------------------------------------------------
# CloudWatch Dashboard
# ---------------------------------------------------------
# Provides a single view of the application, ALB and RDS
# health metrics.

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-monitoring"

  dashboard_body = jsonencode({
    widgets = [

      # ---------------------------------------------------
      # Application EC2 CPU
      # ---------------------------------------------------
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Application EC2 CPU Utilization"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              data.terraform_remote_state.application.outputs.autoscaling_group_name
            ]
          ]
        }
      },


      # ---------------------------------------------------
      # ALB Request Count
      # ---------------------------------------------------
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Application Load Balancer Requests"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              data.terraform_remote_state.application.outputs.alb_arn_suffix
            ]
          ]
        }
      },


      # ---------------------------------------------------
      # ALB HTTP 5XX Errors
      # ---------------------------------------------------
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "ALB HTTP 5XX Errors"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Sum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              data.terraform_remote_state.application.outputs.alb_arn_suffix
            ]
          ]
        }
      },


      # ---------------------------------------------------
      # ALB Unhealthy Hosts
      # ---------------------------------------------------
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "ALB Unhealthy Application Instances"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Maximum"

          metrics = [
            [
              "AWS/ApplicationELB",
              "UnHealthyHostCount",
              "LoadBalancer",
              data.terraform_remote_state.application.outputs.alb_arn_suffix,
              "TargetGroup",
              data.terraform_remote_state.application.outputs.target_group_arn_suffix
            ]
          ]
        }
      },


      # ---------------------------------------------------
      # RDS CPU
      # ---------------------------------------------------
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "RDS CPU Utilization"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "AWS/RDS",
              "CPUUtilization",
              "DBInstanceIdentifier",
              data.terraform_remote_state.database.outputs.rds_instance_id
            ]
          ]
        }
      },


      # ---------------------------------------------------
      # RDS Database Connections
      # ---------------------------------------------------
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "RDS Database Connections"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "AWS/RDS",
              "DatabaseConnections",
              "DBInstanceIdentifier",
              data.terraform_remote_state.database.outputs.rds_instance_id
            ]
          ]
        }
      },


      # ---------------------------------------------------
      # RDS Free Storage
      # ---------------------------------------------------
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          title  = "RDS Free Storage Space"
          region = var.aws_region
          view   = "timeSeries"
          period = 300
          stat   = "Average"

          metrics = [
            [
              "AWS/RDS",
              "FreeStorageSpace",
              "DBInstanceIdentifier",
              data.terraform_remote_state.database.outputs.rds_instance_id
            ]
          ]
        }
      }
    ]
  })
}
