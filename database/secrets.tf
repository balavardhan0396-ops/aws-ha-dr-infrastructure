# ---------------------------------------------------------
# Generate Database Password
# ---------------------------------------------------------

resource "random_password" "db" {
  length  = 32
  special = true

  override_special = "!#$%&*+-=?@^_"
}


# ---------------------------------------------------------
# AWS Secrets Manager Secret
# ---------------------------------------------------------

resource "aws_secretsmanager_secret" "db" {
  name = "${var.project_name}/${var.environment}/database"

  description = "Credentials for the ${var.project_name} RDS MySQL database"

  # For this lab environment, permanently delete the secret
  # immediately when Terraform destroys it.
  recovery_window_in_days = 0

  tags = {
    Name = "${var.project_name}-database-secret"
  }
}


# ---------------------------------------------------------
# Store Database Credentials in Secrets Manager
# ---------------------------------------------------------

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    database = var.db_name
  })
}
