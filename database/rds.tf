
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-mysql"

  engine         = "mysql"
  engine_version = var.db_engine_version

  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"

  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db.result

  port = 3306

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [
    data.terraform_remote_state.network.outputs.db_security_group_id
  ]

  multi_az = true

  publicly_accessible = false

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window

  maintenance_window = var.maintenance_window

  auto_minor_version_upgrade = true

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  copy_tags_to_snapshot = true

  apply_immediately = true

  tags = {
    Name = "${var.project_name}-${var.environment}-mysql"
  }
}
