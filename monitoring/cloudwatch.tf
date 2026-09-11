# ---------------------------------------------------------
# Remote State: Network
# ---------------------------------------------------------

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "network/terraform.tfstate"
    region = var.aws_region
  }
}

# ---------------------------------------------------------
# Remote State: Database
# ---------------------------------------------------------

data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "database/terraform.tfstate"
    region = var.aws_region
  }
}

# ---------------------------------------------------------
# Remote State: Application
# ---------------------------------------------------------

data "terraform_remote_state" "application" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "application/terraform.tfstate"
    region = var.aws_region
  }
}
