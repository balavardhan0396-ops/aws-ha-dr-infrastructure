# =========================================================
# Remote State - Network
# =========================================================

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "01-network/terraform.tfstate"
    region = var.aws_region
  }
}


# =========================================================
# Remote State - Database
# =========================================================

data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "02-database/terraform.tfstate"
    region = var.aws_region
  }
}


# =========================================================
# EC2 IAM Role
# =========================================================

resource "aws_iam_role" "app" {
  name = "${var.project_name}-${var.environment}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-app-role"
  }
}


# =========================================================
# Secrets Manager Access Policy
# =========================================================

resource "aws_iam_role_policy" "secrets" {
  name = "${var.project_name}-app-secrets-policy"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = data.terraform_remote_state.database.outputs.db_secret_arn
      }
    ]
  })
}


# =========================================================
# CloudWatch Agent Policy
# =========================================================

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}


# =========================================================
# EC2 Instance Profile
# =========================================================

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-${var.environment}-app-profile"

  role = aws_iam_role.app.name

  tags = {
    Name = "${var.project_name}-app-profile"
  }
}
