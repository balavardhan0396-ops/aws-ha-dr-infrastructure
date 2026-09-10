
resource "aws_eip" "nat" {
  count = length(var.availability_zones)

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "main" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [
    aws_internet_gateway.main
  ]

  tags = {
    Name = "${var.project_name}-nat-${count.index + 1}"
  }
}
