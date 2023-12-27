# Configuración de la VPC Pública
resource "aws_vpc" "public_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "PublicVPC"
  }
}

# Subred Pública
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.public_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# Configuración de la VPC Privada
resource "aws_vpc" "private_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "PrivateVPC"
  }
}

# Subred Privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.private_vpc.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "PrivateSubnet"
  }
}

# Peering VPC
resource "aws_vpc_peering_connection" "peering" {
  peer_vpc_id = aws_vpc.public_vpc.id
  vpc_id      = aws_vpc.private_vpc.id
  auto_accept = true

  tags = {
    Name = "VPCPeering"
  }
}

# Security Groups
resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.public_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.private_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Recursos para instancias EC2 en cada VPC
resource "aws_instance" "public_instance" {
  ami            = "ami-079db87dc4c10ac91"
  instance_type  = "t2.micro"
  subnet_id      = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]


  tags = {
    Name = "PublicEC2"
  }
}

resource "aws_instance" "private_instance" {
  ami            = "ami-079db87dc4c10ac91"
  instance_type  = "t2.micro"
  subnet_id      = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]


  tags = {
    Name = "PrivateEC2"
  }
}