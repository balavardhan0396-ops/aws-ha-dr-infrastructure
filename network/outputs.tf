output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the network."
  value       = var.availability_zones
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "CIDRs of the public subnets."
  value       = aws_subnet.public[*].cidr_block
}

output "app_subnet_ids" {
  description = "IDs of the private application subnets."
  value       = aws_subnet.app[*].id
}

output "app_subnet_cidrs" {
  description = "CIDRs of the private application subnets."
  value       = aws_subnet.app[*].cidr_block
}

output "db_subnet_ids" {
  description = "IDs of the private database subnets."
  value       = aws_subnet.db[*].id
}

output "db_subnet_cidrs" {
  description = "CIDRs of the private database subnets."
  value       = aws_subnet.db[*].cidr_block
}

output "alb_security_group_id" {
  description = "Security group ID for the Application Load Balancer."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID for application EC2 instances."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security group ID for RDS."
  value       = aws_security_group.db.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways."
  value       = aws_nat_gateway.main[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.main.id
}
