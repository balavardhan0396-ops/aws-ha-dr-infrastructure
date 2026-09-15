data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "simple_vm" {
  name        = "simple-application-vm-sg"
  description = "Security group for simple application VM"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my current IP - temporarily adjust if required"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Application port"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "simple-application-vm-sg"
  }
}

resource "aws_instance" "application_vm" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.simple_vm.id]

  associate_public_ip_address = true

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "simple-application-vm"
    Tier = "Application"
  }
}
