# ---------------------------------------------------------
# Read Network Infrastructure from Remote State
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
# RDS DB Subnet Group
# Uses private DB subnets created by 01-network
# ---------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = data.terraform_remote_state.network.outputs.db_subnet_ids

  description = "Private database subnets for RDS Multi-AZ"

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}
