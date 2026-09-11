# ---------------------------------------------------------
# Remote state: Application
# ---------------------------------------------------------

data "terraform_remote_state" "application_cloudfront" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "application/terraform.tfstate"
    region = var.aws_region
  }
}
