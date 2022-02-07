# Creating VPC,name, CIDR and Tags
resource "aws_vpc" "dev" {
cidr_block           = "10.0.0.0/16"
instance_tenancy     = "default"
enable_dns_support   = "true"
enable_dns_hostnames = "true"
enable_classiclink   = "false"
tags = {
Name = "dev"
}
}
# Creating Public Subnets in VPC
resource "aws_subnet" "dev-public-1" {
vpc_id                  = aws_vpc.dev.id
cidr_block              = "10.0.1.0/24"
map_public_ip_on_launch = "true"
availability_zone       = "ap-south-1a"
tags = {
Name = "dev-public-1"
}
}
resource "aws_subnet" "dev-public-2" {
vpc_id                  = aws_vpc.dev.id
cidr_block              = "10.0.2.0/24"
map_public_ip_on_launch = "true"
availability_zone       = "ap-south-1b"
tags = {
Name = "dev-public-2"
}
}
# Creating Private Subnets in VPC
resource "aws_subnet" "dev-private-1" {
vpc_id                  = aws_vpc.dev.id
cidr_block              = "10.0.3.0/24"
map_public_ip_on_launch = "false"
availability_zone       = "ap-south-1a"
tags = {
Name = "dev-private-1"
}
}
resource "aws_subnet" "dev-private-2" {
vpc_id                  = aws_vpc.dev.id
cidr_block              = "10.0.4.0/24"
map_public_ip_on_launch = "false"
availability_zone       = "ap-south-1b"
tags = {
Name = "dev-private-2"
}
}
# Creating Internet Gateway in AWS VPC
resource "aws_internet_gateway" "dev-gw" {
vpc_id = aws_vpc.dev.id
tags = {
Name = "dev"
}
}
# Creating Route Tables for Internet gateway
resource "aws_route_table" "dev-public" {
vpc_id = aws_vpc.dev.id
route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.dev-gw.id
}
tags = {
Name = "dev-public-1"
}
}
# Creating Route Associations public subnets
resource "aws_route_table_association" "dev-public-1-a" {
subnet_id      = aws_subnet.dev-public-1.id
route_table_id = aws_route_table.dev-public.id
}
resource "aws_route_table_association" "dev-public-2-a" {
subnet_id      = aws_subnet.dev-public-2.id
route_table_id = aws_route_table.dev-public.id
}
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

resource "aws_security_group" "sg" {
  name        = "amazon-Server-SG"
  description = "Restrictions for Citizix server"
  vpc_id      = aws_vpc.dev.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "amazon-Server-SG"
  }
}

resource "aws_instance" "instance" {
  ami                         = "ami-03fa4afc89e4a8a09"
  instance_type               = "t2.small"
  key_name                    = aws_key_pair.generated_key.key_name
  subnet_id                   = aws_subnet.dev-public-1.id
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 50
    delete_on_termination = true
  }

  tags = {
    Name = "new-ec2-instance"
  }
}


output "instance-private-ip" {
  value = aws_instance.instance.private_ip
}

output "instance-public-ip" {
  value = aws_instance.instance.public_ip
}
