data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "network/terraform.tfstate"
    region = var.aws_region
  }
}

resource "aws_db_subnet_group" "app" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = data.terraform_remote_state.network.outputs.db_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  }
}
