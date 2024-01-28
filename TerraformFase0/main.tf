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

# route table public subnet
resource "aws_route_table" "public_subnet1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    "Name" = "public-rt1"
  }

} 

# route table public subnet association
resource "aws_route_table_association" "public_subnet_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_subnet1.id
}


resource "aws_route" "default_route_public_subnet1" {
  route_table_id         = aws_route_table.public_subnet1.id
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
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids     =  [aws_security_group.sg1.id]
 
 user_data = file("userdata.sh")

  tags = {
    Name = "webtodo"

}

}
