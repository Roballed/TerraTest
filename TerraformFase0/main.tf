#VPC1
resource "aws_vpc" "vpc1" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "spoke-vpc1"

  }
}

# internet gateway
resource "aws_internet_gateway" "internet_gateway1" {
  vpc_id = aws_vpc.vpc1.id

  tags ={
    Name = "IGW1"
  }
}

# Subnet1
resource "aws_subnet" "public_subnet1" {
 
  cidr_block        = "10.1.0.0/24"
  vpc_id            = aws_vpc.vpc1.id
    tags = {
    Name = "public-subnet-1"
}
}

# Subnet2
resource "aws_subnet" "public_subnet2" {
 
  cidr_block        = "10.1.1.0/24"
  vpc_id            = aws_vpc.vpc1.id
    tags = {
    Name = "public-subnet-2"
}
}

# Subnet3 privada
resource "aws_subnet" "private_subnet1" {
 
  cidr_block        = "10.1.2.0/24"
  vpc_id            = aws_vpc.vpc1.id
    tags = {
    Name = "private-subnet-2"
}
}

# route table public subnet1
resource "aws_route_table" "public_subnet1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    "Name" = "public-rt1"
  }

} 

# route table public subnet2
resource "aws_route_table" "public_subnet2" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    "Name" = "public-rt2"
  }

} 

# route table private subnet1
resource "aws_route_table" "private_subnet1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    "Name" = "private-rt1"
  }

} 

# route table public subnet1 association
resource "aws_route_table_association" "public_subnet_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_subnet1.id
}

# route table public subnet2 association
resource "aws_route_table_association" "public_subnet_association2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_subnet2.id
}

# route table private subnet1 association
resource "aws_route_table_association" "private_subnet_association1" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.private_subnet1.id
}

resource "aws_route" "default_route_public_subnet1" {
  route_table_id         = aws_route_table.public_subnet1.id
  destination_cidr_block = var.default_route
  gateway_id             = aws_internet_gateway.internet_gateway1.id
}

resource "aws_route" "default_route_public_subnet2" {
  route_table_id         = aws_route_table.public_subnet2.id
  destination_cidr_block = var.default_route
  gateway_id             = aws_internet_gateway.internet_gateway1.id
}



# Create SG1

resource "aws_security_group" "sg1" {
  name        = "sg1"
  description = "allow ssh and http port80"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 80
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

 
  tags = {
    Name = "sg1"
    
  }
}

resource "aws_instance" "webtodo" {
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.private_subnet1.id
  vpc_security_group_ids     =  [aws_security_group.sg1.id]
 
 user_data = file("userdata.sh")

  tags = {
    Name = "webtodo"

}

}
