# =========================================================
# PUBLIC NACL
# =========================================================

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-public-nacl"
  }
}

# Allow HTTP inbound
resource "aws_network_acl_rule" "public_http_ingress" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 100
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = "0.0.0.0/0"

  from_port = 80
  to_port   = 80
}

# Allow HTTPS inbound
resource "aws_network_acl_rule" "public_https_ingress" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 110
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = "0.0.0.0/0"

  from_port = 443
  to_port   = 443
}

# Allow ephemeral return traffic
resource "aws_network_acl_rule" "public_ephemeral_ingress" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 120
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = "0.0.0.0/0"

  from_port = 1024
  to_port   = 65535
}

# Allow outbound traffic
resource "aws_network_acl_rule" "public_egress" {
  network_acl_id = aws_network_acl.public.id

  rule_number = 100
  egress      = true

  protocol    = "-1"
  rule_action = "allow"

  cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_association" "public" {
  count = length(var.availability_zones)

  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public[count.index].id
}


# =========================================================
# APPLICATION NACL
# =========================================================

resource "aws_network_acl" "app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-app-nacl"
  }
}

# Allow ALB/application traffic inside VPC
resource "aws_network_acl_rule" "app_ingress" {
  network_acl_id = aws_network_acl.app.id

  rule_number = 100
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = var.vpc_cidr

  from_port = var.app_port
  to_port   = var.app_port
}

# Allow ephemeral return traffic
resource "aws_network_acl_rule" "app_ephemeral_ingress" {
  network_acl_id = aws_network_acl.app.id

  rule_number = 110
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = var.vpc_cidr

  from_port = 1024
  to_port   = 65535
}

# Application outbound
resource "aws_network_acl_rule" "app_egress" {
  network_acl_id = aws_network_acl.app.id

  rule_number = 100
  egress      = true

  protocol    = "-1"
  rule_action = "allow"

  cidr_block = "0.0.0.0/0"
}

resource "aws_network_acl_association" "app" {
  count = length(var.availability_zones)

  network_acl_id = aws_network_acl.app.id
  subnet_id      = aws_subnet.app[count.index].id
}


# =========================================================
# DATABASE NACL
# =========================================================

resource "aws_network_acl" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-db-nacl"
  }
}

# Allow MySQL only from application subnets
resource "aws_network_acl_rule" "db_mysql_ingress" {
  count = length(var.app_subnet_cidrs)

  network_acl_id = aws_network_acl.db.id

  rule_number = 100 + count.index
  egress      = false

  protocol    = "tcp"
  rule_action = "allow"

  cidr_block = var.app_subnet_cidrs[count.index]

  from_port = 3306
  to_port   = 3306
}

# Allow DB return traffic inside the VPC
resource "aws_network_acl_rule" "db_egress" {
  network_acl_id = aws_network_acl.db.id

  rule_number = 100
  egress      = true

  protocol    = "-1"
  rule_action = "allow"

  cidr_block = var.vpc_cidr
}

resource "aws_network_acl_association" "db" {
  count = length(var.availability_zones)

  network_acl_id = aws_network_acl.db.id
  subnet_id      = aws_subnet.db[count.index].id
}
