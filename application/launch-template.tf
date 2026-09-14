resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/${var.project_name}/${var.environment}/application"
  retention_in_days = 30

  tags = {
    Name = "${var.project_name}-${var.environment}-application-logs"
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-app-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  vpc_security_group_ids = [
    data.terraform_remote_state.network.outputs.app_security_group_id
  ]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  user_data = base64encode(<<-EOF
#!/bin/bash

set -e

dnf update -y
dnf install -y docker jq awscli-2

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user || true

mkdir -p /opt/app

ECR_REGISTRY=$(echo "${var.app_image}" | cut -d'/' -f1)

aws ecr get-login-password \
  --region ${var.aws_region} | \
  docker login \
  --username AWS \
  --password-stdin "$ECR_REGISTRY"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region ${var.aws_region} \
  --secret-id ${data.terraform_remote_state.database.outputs.db_secret_arn} \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.database')

DB_HOST="${data.terraform_remote_state.database.outputs.rds_address}"
DB_PORT="${data.terraform_remote_state.database.outputs.rds_port}"

TOKEN=$(curl -sS -X PUT \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" \
  http://169.254.169.254/latest/api/token)

INSTANCE_ID=$(curl -sS \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

docker pull ${var.app_image}

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
      Name = "${var.project_name}-${var.environment}-app"
      Tier = "Application"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
