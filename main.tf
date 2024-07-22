provider "aws" {
  region     = "ap-south-1"
  access_key = "your key"
  secret_key = "replace yours"
}
resource "aws_vpc" "Adiinfra" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Adiinfra_project"
  }
}
resource "aws_subnet" "frontend-subnet-1" {
  vpc_id     = aws_vpc.Adiinfra.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "frontend-subnet-1"
  }
}
resource "aws_subnet" "frontend-subnet-2" {
  vpc_id     = aws_vpc.Adiinfra.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "frontend-subnet-2"
  }
}

resource "aws_subnet" "backend-subnet-1" {
  vpc_id     = aws_vpc.Adiinfra.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "backend-subnet-1"
  }
}
resource "aws_subnet" "backend-subnet-2" {
  vpc_id     = aws_vpc.Adiinfra.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "backend-subnet-2"
  }
}
resource "aws_subnet" "db-subnet-1" {
  vpc_id     = aws_vpc.Adiinfra.id
  cidr_block = "10.0.5.0/24"

  tags = {
    Name = "db-subnet-2"
  }
}
resource "aws_subnet" "db-subnet-2" {
  vpc_id     = aws_vpc.Adiinfra.id
  cidr_block = "10.0.6.0/24"

  tags = {
    Name = "db-subnet-2"
  }
}
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.Adiinfra.id
  cidr_block = "10.0.7.0/24"

  tags = {
    Name = "public-subnet-1"
  }
}
resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.Adiinfra.id
  cidr_block = "10.0.8.0/24"

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_security_group" "public-sg" {
   vpc_id     = aws_vpc.Adiinfra.id
  # ... other configuration ...

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group" "frontend-sg" {
   vpc_id     = aws_vpc.Adiinfra.id
  # ... other configuration ...

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "frontend-sg"
  }
}
resource "aws_security_group" "backend-sg" {
   vpc_id     = aws_vpc.Adiinfra.id
  # ... other configuration ...

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "backend-sg"
  }
}
 
 resource "aws_security_group" "db-sg" {
   vpc_id     = aws_vpc.Adiinfra.id
  # ... other configuration ...

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  tags = {
    Name = "db-sg"
  }
}
 
 # creating igw for public subnet and nat for db,backend,frontend
resource "aws_internet_gateway" "Adiinfra-igw" {
  vpc_id = aws_vpc.Adiinfra.id

  tags = {
    Name = "Adiinfra-igw"
  }
}
# to assign public subnet to igw we need to create igw
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.Adiinfra.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Adiinfra-igw.id
  }

 

  tags = {
    Name = "public-rt"
  }
}

resource "aws_eip" "Adiinfra-natip" {
  domain   = "vpc"
}
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}
# creating nat gatway for all remaingig subnets

resource "aws_nat_gateway" "Adiinfra-natgateway" {
  allocation_id = aws_eip.Adiinfra-natip.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name = "Adiinfra-natgateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
   depends_on = [aws_internet_gateway.Adiinfra-igw]
}
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.Adiinfra.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Adiinfra-natgateway.id
  }
  tags = {
    Name = "private-rt"
  }
}
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.frontend-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.frontend-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}
resource "aws_route_table_association" "e" {
  subnet_id      = aws_subnet.backend-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}
resource "aws_route_table_association" "f" {
  subnet_id      = aws_subnet.backend-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}
resource "aws_route_table_association" "g" {
  subnet_id      = aws_subnet.db-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}
resource "aws_route_table_association" "h" {
  subnet_id      = aws_subnet.db-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}