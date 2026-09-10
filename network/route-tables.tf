# ---------------------------------------------------------
# Public Route Table
# ---------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}


# ---------------------------------------------------------
# Public Route Table Associations
# ---------------------------------------------------------

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# ---------------------------------------------------------
# Private Application Route Tables
# One route table per Availability Zone
# ---------------------------------------------------------

resource "aws_route_table" "app" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.project_name}-app-rt-${count.index + 1}"
  }
}


# ---------------------------------------------------------
# Private Application Route Table Associations
# ---------------------------------------------------------

resource "aws_route_table_association" "app" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}


# ---------------------------------------------------------
# Private Database Route Tables
# One route table per Availability Zone
# No Internet/NAT route
# ---------------------------------------------------------

resource "aws_route_table" "db" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-rt-${count.index + 1}"
  }
}


# ---------------------------------------------------------
# Private Database Route Table Associations
# ---------------------------------------------------------

resource "aws_route_table_association" "db" {
  count = length(var.availability_zones)

  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db[count.index].id
}
