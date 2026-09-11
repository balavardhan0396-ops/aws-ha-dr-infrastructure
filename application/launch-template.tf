# ---------------------------------------------------------
# Application CloudWatch Log Group
# ---------------------------------------------------------

resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/${var.project_name}/${var.environment}/application"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-application-logs"
  }
}

# ---------------------------------------------------------
# EC2 Launch Template
# ---------------------------------------------------------

resource "aws_launch_template" "app" {
  name = "${var.project_name}-${var.environment}-app-lt"

  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  vpc_security_group_ids = [
    data.terraform_remote_state.network.outputs.app_security_group_id
  ]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash

    set -e

    # -----------------------------------------------------
    # Install required packages
    # -----------------------------------------------------

    dnf update -y
    dnf install -y docker jq

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ec2-user

    # -----------------------------------------------------
    # Get EC2 Instance ID using IMDSv2
    # -----------------------------------------------------

    TOKEN=$(curl -sS -X PUT \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
      http://169.254.169.254/latest/api/token)

    INSTANCE_ID=$(curl -sS \
      -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)

    # -----------------------------------------------------
    # Login to Amazon ECR
    # -----------------------------------------------------

    ECR_REGISTRY=$(echo "${var.app_image}" | cut -d'/' -f1)

    aws ecr get-login-password \
      --region ${var.aws_region} \
      | docker login \
        --username AWS \
        --password-stdin "$ECR_REGISTRY"

    # -----------------------------------------------------
    # Retrieve database credentials
    # -----------------------------------------------------

    SECRET_JSON=$(aws secretsmanager get-secret-value \
      --secret-id ${data.terraform_remote_state.database.outputs.db_secret_arn} \
      --query SecretString \
      --output text \
      --region ${var.aws_region})

    DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
    DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')
    DB_NAME=$(echo "$SECRET_JSON" | jq -r '.database')

    DB_HOST="${data.terraform_remote_state.database.outputs.rds_address}"
    DB_PORT="${data.terraform_remote_state.database.outputs.rds_port}"

    # -----------------------------------------------------
    # Pull application image
    # -----------------------------------------------------

    docker pull ${var.app_image}

    # -----------------------------------------------------
    # Start application container
    # -----------------------------------------------------

    docker rm -f three-tier-app 2>/dev/null || true

    docker run -d \
      --name three-tier-app \
      --restart unless-stopped \
      -p ${var.app_port}:${var.app_port} \
      -e DB_HOST="$DB_HOST" \
      -e DB_PORT="$DB_PORT" \
      -e DB_USER="$DB_USER" \
      -e DB_PASSWORD="$DB_PASSWORD" \
      -e DB_NAME="$DB_NAME" \
      --log-driver=awslogs \
      --log-opt awslogs-region=${var.aws_region} \
      --log-opt awslogs-group=/aws/${var.project_name}/${var.environment}/application \
      --log-opt awslogs-stream="$INSTANCE_ID" \
      ${var.app_image}

  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-app"
      Tier = "Application"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
