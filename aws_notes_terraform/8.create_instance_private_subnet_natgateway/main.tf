#creating vpc, nat_gateway, internet_gateway, route table, subnet, associate the subnet to route table and security_group
##launch instances in  public_subnet with internet_gateway and private_subnet with nat_gateway
###now add nat_gateway to get the Internet
#1.create the nat_gateway in public_subnets
#2.update the route table of private subnet and the route for Internet traffic 0.0.0.0/0 using NAT gateway
#provider
provider "aws" {
  region = "ap-south-1"
}

####creating the vpc with main name
#resource "<provider>_<resource_type>" "name" {
resource "aws_vpc" "VPC-A" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "prod-${var.vpc_name}"
  }
}
###allocating elastic ip  associate_public_ip_address
resource "aws_eip" "nat_gateway" {
  vpc = true
}
###create internet_gateway and nat_gateway
##internet_gateway
resource "aws_internet_gateway" "VPC-A-IGW" {
  vpc_id = aws_vpc.VPC-A.id

  tags = {
    Name = "${var.vpc_name}-IGW"
  }
}
##nat_gateway
resource "aws_nat_gateway" "VPC-A-NGW" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.Public-Subnet-A.id
  tags = {
    "Name" = "${var.vpc_name}-NGW"
  }
}
###create the route table
#creating the public_route_table
resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.VPC-A.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC-A-IGW.id
  }

  tags = {
    Name = "Public-RT-${var.name[0]}"
  }
}
#creating the private_route_table
resource "aws_route_table" "Private-RT" {
  vpc_id = aws_vpc.VPC-A.id
  route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_nat_gateway.VPC-A-NGW.id
  }

  tags = {
    Name = "Private-RT-${var.name[0]}"
  }
}
###create a subnets
#creating the public_subnet
resource "aws_subnet" "Public-Subnet-A" {
  vpc_id     = aws_vpc.VPC-A.id
  cidr_block = var.public_subnet_cidr_block
  #cidr_block              = "${var.Public_Subnet_1}"
  availability_zone = var.public_subnet_availability_zone
  #map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet-${var.name[0]}"
  }
}
#creating the private_subnet

resource "aws_subnet" "Private-Subnet-A" {
  vpc_id     = aws_vpc.VPC-A.id
  cidr_block = var.private_subnet_cidr_block
  #cidr_block              = "${var.Public_Subnet_1}"
  availability_zone = var.private_subnet_availability_zone
  #map_public_ip_on_launch = true
  tags = {
    Name = "Private-Subnet-${var.name[0]}"
  }
}

## Associate the subnets with route tables
#Associate the public_subnets with public_route_table

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.Public-Subnet-A.id
  route_table_id = aws_route_table.Public-RT.id
}

#Associate the private_subnets with private_route_table
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.Private-Subnet-A.id
  route_table_id = aws_route_table.Private-RT.id
}
#6.create the security group
resource "aws_security_group" "security-group" {
  name        = "allow_ports"
  description = "Allow ports inbound traffic"
  vpc_id      = aws_vpc.VPC-A.id

  # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.vpc_name}-security-group"
  }
}

##creating the ec2-instance in public subnet
resource "aws_instance" "test-terraform" {
  #for_each      = data.aws_subnet.public.ids
  ami                         = var.ami_image_id.redhat
  instance_type               = var.instance_type[0]
  key_name                    = var.key_pair
  associate_public_ip_address = true
  #availability_zone            = var.availability_zone.AZ1
  #instance_state               = "running"
  #security_groups -- it for new security group while ec2_instance creating
  vpc_security_group_ids = [aws_security_group.security-group.id]
  #subnet_id = var.public_subnet_id
  subnet_id = aws_subnet.Public-Subnet-A.id
  #tenancy = tenancy
  tags = {
    Name = "public-${var.tags}"
  }
}

##creating the ec2-instance in private subnet
resource "aws_instance" "test-terraform-1" {
  #for_each      = data.aws_subnet.public.ids
  ami                         = var.ami_image_id.redhat
  instance_type               = var.instance_type[0]
  key_name                    = var.key_pair
  associate_public_ip_address = true
  #availability_zone            = var.availability_zone.AZ2
  #instance_state               = "running"
  #security_groups -- it for new security group while ec2_instance creating
  vpc_security_group_ids = [aws_security_group.security-group.id ]
  #subnet_id = var.public_subnet_id
  subnet_id = aws_subnet.Private-Subnet-A.id
  #tenancy = tenancy
  tags = {
    Name = "private-${var.tags}"
  }
}
