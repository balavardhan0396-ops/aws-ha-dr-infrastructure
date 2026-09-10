# Read outputs from the previously deployed Terraform phases.
# These remote states allow this security phase to reference
# resources created by the network, database, and application phases.

data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "01-network/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "02-database/terraform.tfstate"
    region = var.aws_region
  }
}

data "terraform_remote_state" "application" {
  backend = "s3"

  config = {
    bucket = "aws-ha-dr-terraform-state"
    key    = "03-application/terraform.tfstate"
    region = var.aws_region
  }
}


# IAM role used for security auditing and inspection.
#
# This is separate from the application IAM role created
# in 03-application/iam.tf.
#
# The application EC2 instances continue to use the
# application role from Phase 3.

resource "aws_iam_role" "security_audit" {
  name = "${var.project_name}-${var.environment}-security-audit-role"

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
    Name = "${var.project_name}-security-audit-role"
  }
}


# AWS managed SecurityAudit policy.
#
# This provides read-only security auditing permissions
# across AWS services without granting permissions to
# modify infrastructure.

resource "aws_iam_role_policy_attachment" "security_audit" {
  role       = aws_iam_role.security_audit.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}
