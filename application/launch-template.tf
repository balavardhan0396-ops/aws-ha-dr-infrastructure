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

  user_data = base64encode(<<-EOF
    #!/bin/bash

    set -e

    # Update operating system
    dnf update -y

    # Install Docker
    dnf install -y docker

    # Start Docker
    systemctl enable docker
    systemctl start docker

    # Allow ec2-user to use Docker
    usermod -aG docker ec2-user

    # Create application directory
    mkdir -p /opt/app

    # Store database configuration
    cat > /opt/app/database.env <<'ENV'
    DB_HOST=${data.terraform_remote_state.database.outputs.rds_address}
    DB_PORT=${data.terraform_remote_state.database.outputs.rds_port}
    DB_NAME=${data.terraform_remote_state.database.outputs.rds_database_name}
    DB_SECRET_ARN=${data.terraform_remote_state.database.outputs.db_secret_arn}
    ENV

    # Pull and start application container
    docker pull ${var.app_image}

    docker run -d \
      --name three-tier-app \
      --restart unless-stopped \
      -p ${var.app_port}:${var.app_port} \
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
