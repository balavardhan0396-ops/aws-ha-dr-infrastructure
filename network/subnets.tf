
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index + 1}"
    Tier = "Public"
  }
}

resource "aws_subnet" "app" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.app_subnet_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-app-${count.index + 1}"
    Tier = "Application"
  }
}

resource "aws_subnet" "db" {
  count = length(var.availability_zones)

  vpc_id                  = aws_vpc.main.id
  availability_zone       = var.availability_zones[count.index]
  cidr_block              = var.db_subnet_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-db-${count.index + 1}"
    Tier = "Database"
  }
}
