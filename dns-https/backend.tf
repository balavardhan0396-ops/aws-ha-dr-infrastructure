terraform {
  backend "s3" {
    bucket       = "aws-ha-dr-terraform-state"
    key          = "dns-https/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true
  }
}
