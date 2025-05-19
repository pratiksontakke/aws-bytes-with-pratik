# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

# Data source to get available AZs in the chosen region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC (Virtual Private Cloud)
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "pratik-vpc-demo"
  }
}

# Create a public subnet in the first Availability Zone
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0] # e.g., ap-south-1a
  map_public_ip_on_launch = true                                           # For demo purposes to SSH easily

  tags = {
    Name = "pratik-public-subnet-az1"
  }
}

# Create a public subnet in the second Availability Zone
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1] # e.g., ap-south-1b
  map_public_ip_on_launch = true                                           # For demo purposes

  tags = {
    Name = "pratik-public-subnet-az2"
  }
}

# Define an AMI (Amazon Machine Image) - Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch an EC2 instance in the first AZ
resource "aws_instance" "server_az1" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro" # Use free tier eligible type
  subnet_id     = aws_subnet.public_subnet_az1.id
  key_name      = "aws_linux_mumbai"

  tags = {
    Name = "WebServer-AZ1-Pratik"
  }
}

# Launch an EC2 instance in the second AZ
resource "aws_instance" "server_az2" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro" # Use free tier eligible type
  subnet_id     = aws_subnet.public_subnet_az2.id
  key_name      = "aws_linux_mumbai"

  tags = {
    Name = "WebServer-AZ2-Pratik"
  }
}

# (Output instance details)
output "server_az1_public_ip" {
  description = "Public IP of Server in AZ1"
  value       = aws_instance.server_az1.public_ip
}

output "server_az1_az" {
  description = "Availability Zone of Server in AZ1"
  value       = aws_instance.server_az1.availability_zone
}

output "server_az2_public_ip" {
  description = "Public IP of Server in AZ2"
  value       = aws_instance.server_az2.public_ip
}

output "server_az2_az" {
  description = "Availability Zone of Server in AZ2"
  value       = aws_instance.server_az2.availability_zone
}