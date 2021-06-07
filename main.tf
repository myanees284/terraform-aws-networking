#Create VPC aws_vpc is resource type(keyword) and main is logical name
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "terraform_vpc_${terraform.workspace}"
  }
}

#creating public subnet
resource "aws_subnet" "public" {
  count             = length(local.az_names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = local.az_names[count.index]

  tags = {
    Name = "${terraform.workspace}_public_subnet_${count.index + 1}"
  }
}
#Create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW"
  }
}

#Create public route table and attaching internet gateway
// resource "aws_route_table" "public_RT" {
//   vpc_id = aws_vpc.main.id

//   route {
//     cidr_block = "0.0.0.0/0"
//     gateway_id = aws_internet_gateway.igw.id
//   }
//   tags = {
//     Name = "public_RT_${terraform.workspace}"
//   }
// }

# Attaching internet gateway to the default route table
resource "aws_default_route_table" "public_RT" {
  default_route_table_id = aws_vpc.main.main_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

#Associating public subnets with route table
resource "aws_route_table_association" "public" {
  count          = length(local.public_subnet_ids)
  subnet_id      = local.public_subnet_ids[count.index]
  route_table_id = aws_default_route_table.public_RT.id
}

#creating private subnet
resource "aws_subnet" "private" {
  count  = length(local.az_names)
  vpc_id = aws_vpc.main.id
  #to create private subnet CIDR without any overlapping with public subnet
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(local.public_subnet_ids))
  availability_zone = local.az_names[count.index]

  tags = {
    Name = "${terraform.workspace}_private_subnet_${count.index + 1}"
  }
}

#Create route table
resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }
  tags = {
    Name = "${terraform.workspace}_private_RT"
  }
}

// #Associating private subnets with route table
resource "aws_route_table_association" "private" {
  count          = length(local.private_subnet_ids)
  subnet_id      = local.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private_RT.id
}

#Creating elastic ip
resource "aws_eip" "nat" {
  vpc = true
}

// #Create NAT gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = local.public_subnet_ids[0]

  tags = {
    Name = "${terraform.workspace}_NAT_GW"
  }
}