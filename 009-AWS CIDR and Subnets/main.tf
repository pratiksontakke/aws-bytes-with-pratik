# main.tf

provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

# 1. Define the "Housing Society" (VPC)
resource "aws_vpc" "my_housing_society_vpc" {
  cidr_block           = "10.10.0.0/16" # Our main address plan for the entire society
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name  = "MyHousingSociety-VPC-Pratik"
    Owner = "Pratik Sontakke Tech"
  }
}

# Data source to get available AZs in the chosen region for dynamic assignment
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. Define "Street 1" (Public Subnet in AZ-a)
resource "aws_subnet" "mg_road_public_subnet_az1" {
  vpc_id                  = aws_vpc.my_housing_society_vpc.id
  cidr_block              = "10.10.1.0/24" # Specific address range for this street
  availability_zone       = data.aws_availability_zones.available.names[0] # e.g., ap-south-1a
  map_public_ip_on_launch = true         # Instances here can get public IPs (if IGW & Route Table configured)

  tags = {
    Name = "MGRoad-Public-Subnet-AZ1-Pratik"
    Type = "Public"
  }
}

# 3. Define "Street 2" (Private Subnet in AZ-a)
resource "aws_subnet" "tagore_lane_private_subnet_az1" {
  vpc_id            = aws_vpc.my_housing_society_vpc.id
  cidr_block        = "10.10.2.0/24" # Specific address range for this street
  availability_zone = data.aws_availability_zones.available.names[0] # e.g., ap-south-1a

  tags = {
    Name = "TagoreLane-Private-Subnet-AZ1-Pratik"
    Type = "Private"
  }
}

# 4. Define "Street 3" (Public Subnet in AZ-b for HA)
resource "aws_subnet" "nehru_park_public_subnet_az2" {
  vpc_id                  = aws_vpc.my_housing_society_vpc.id
  cidr_block              = "10.10.3.0/24" # Specific address range for this street
  availability_zone       = data.aws_availability_zones.available.names[1] # e.g., ap-south-1b
  map_public_ip_on_launch = true

  tags = {
    Name = "NehruPark-Public-Subnet-AZ2-Pratik"
    Type = "Public"
  }
}

# (For a complete setup, you'd add Internet Gateway, Route Tables, etc.)

output "vpc_id" {
  description = "ID of MyHousingSociety VPC"
  value       = aws_vpc.my_housing_society_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of MyHousingSociety VPC"
  value       = aws_vpc.my_housing_society_vpc.cidr_block
}

output "public_subnet_az1_cidr" {
  description = "CIDR block of Public Subnet in AZ1"
  value       = aws_subnet.mg_road_public_subnet_az1.cidr_block
}

output "private_subnet_az1_cidr" {
  description = "CIDR block of Private Subnet in AZ1"
  value       = aws_subnet.tagore_lane_private_subnet_az1.cidr_block
}

output "public_subnet_az2_cidr" {
  description = "CIDR block of Public Subnet in AZ2"
  value       = aws_subnet.nehru_park_public_subnet_az2.cidr_block
}