# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1" # Example: Mumbai Region
}

# 1. Create a VPC (Virtual Private Cloud)
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16" # Main IP address range for our "gated community"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "pratik-tf-vpc"
    Owner = "Pratik Sontakke Tech"
  }
}

# 2. Create a Public Subnet
# This subnet will be associated with our Internet Gateway for public internet access.
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24" # IP address range for this "street"
  availability_zone       = "ap-south-1a" # Example: ap-south-1a
  map_public_ip_on_launch = true          # Instances launched here get a public IP

  tags = {
    Name = "pratik-tf-public-subnet-1"
  }
}

# 3. Create an Internet Gateway (IGW)
# This is the "main gate" for our VPC to access the internet.
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "pratik-tf-igw"
  }
}

# 4. Create a Route Table
# These are the "signboards" directing traffic.
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  # Route for internet-bound traffic (0.0.0.0/0) to go through the IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "pratik-tf-public-rt"
  }
}

# 5. Associate the Route Table with our Public Subnet
# Connecting the "signboards" to our "street".
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Optional: Output the VPC ID and Public Subnet ID
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_1_id" {
  description = "ID of the Public Subnet 1"
  value       = aws_subnet.public_subnet_1.id
}