terraform {
  backend "s3" {
    bucket       = "aws-ha-dr-terraform-state"
    key          = "security/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }
}
