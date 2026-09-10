terraform {
  backend "s3" {
    bucket       = "aws-ha-dr-terraform-state"
    key          = "02-database/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }
}
