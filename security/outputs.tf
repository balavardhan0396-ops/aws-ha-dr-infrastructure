output "kms_key_id" {
  description = "ID of the security KMS key"
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "ARN of the security KMS key"
  value       = aws_kms_key.main.arn
}

output "kms_alias" {
  description = "Alias of the security KMS key"
  value       = aws_kms_alias.main.name
}

output "security_audit_role_arn" {
  description = "ARN of the security audit IAM role"
  value       = aws_iam_role.security_audit.arn
}
