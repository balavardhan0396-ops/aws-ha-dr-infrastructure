# ---------------------------------------------------------
# Public Network ACL
# ---------------------------------------------------------

resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-nacl"
  }
}


# ---------------------------------------------------------
# Public NACL - Inbound
# ---------------------------------------------------------

resource "aws_network_acl_rule" "public_ingress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}


# ---------------------------------------------------------
# Public NACL - Outbound
# ---------------------------------------------------------

resource "aws_network_acl_rule" "public_egress" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}


# ---------------------------------------------------------
# Public NACL - Subnet Associations
# ---------------------------------------------------------

resource "aws_network_acl_association" "public" {
  count = length(var.availability_zones)

  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public[count.index].id
}


# =========================================================
# Application Network ACL
# =========================================================

resource "aws_network_acl" "app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app-nacl"
  }
}


# ---------------------------------------------------------
# Application NACL - Inbound
# ---------------------------------------------------------

resource "aws_network_acl_rule" "app_ingress" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}


# ---------------------------------------------------------
# Application NACL - Outbound
# ---------------------------------------------------------

resource "aws_network_acl_rule" "app_egress" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}


# ---------------------------------------------------------
# Application NACL - Subnet Associations
# ---------------------------------------------------------

resource "aws_network_acl_association" "app" {
  count = length(var.availability_zones)

  network_acl_id = aws_network_acl.app.id
  subnet_id      = aws_subnet.app[count.index].id
}


# =========================================================
# Database Network ACL
# =========================================================

resource "aws_network_acl" "db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-nacl"
  }
}


# ---------------------------------------------------------
# Database NACL - Inbound
# ---------------------------------------------------------

resource "aws_network_acl_rule" "db_ingress" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}


# ---------------------------------------------------------
# Database NACL - Outbound
# ---------------------------------------------------------

resource "aws_network_acl_rule" "db_egress" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}


# ---------------------------------------------------------
# Database NACL - Subnet Associations
# ---------------------------------------------------------

resource "aws_network_acl_association" "db" {
  count = length(var.availability_zones)

  network_acl_id = aws_network_acl.db.id
  subnet_id      = aws_subnet.db[count.index].id
}
