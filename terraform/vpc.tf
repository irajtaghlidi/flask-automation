
# Create VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_prefix

  tags = {
    Name = "App VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app_vpc.id
}

# Create Route Table
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
}


# Create Subnet
resource "aws_subnet" "app" {
    count             = length(var.subnet_prefix)
    depends_on        = [aws_internet_gateway.gw]
    vpc_id            = aws_vpc.app_vpc.id
    cidr_block        = var.subnet_prefix[count.index]
    availability_zone = var.availability_zones[count.index]
}

# Associate subnet with the route table
resource "aws_route_table_association" "a" {
    count          = length(var.subnet_prefix)
    subnet_id      = aws_subnet.app[count.index].id
    route_table_id = aws_route_table.app.id
}