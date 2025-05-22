provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

# Data source to get the latest Amazon Linux 2 AMI ID
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"] # AWS-owned AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"] # Standard Amazon Linux 2 pattern
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a Security Group to allow SSH and HTTP (optional for web server)
resource "aws_security_group" "web_sg" {
  name        = "pratik-ec2-sg"
  description = "Allow SSH and HTTP traffic"
  # vpc_id      = aws_vpc.main_vpc.id # Assuming you have a VPC defined, otherwise uses default

  ingress {
    from_port   = 22 # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For demo only. Restrict to your IP in production!
  }

  ingress {
    from_port   = 80 # HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pratik-web-sg"
  }
}

# Launch an EC2 Instance
resource "aws_instance" "my_first_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro" # Our "scooter" - cost-effective, Free Tier eligible

  # For a more powerful server (our "car" or "truck"), you might use:
  # instance_type = "m5.large"

  key_name               = "aws_linux_mumbai" # REPLACE with your actual key pair name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  # subnet_id     = aws_subnet.public_subnet_1.id # If using a custom VPC/subnet

  tags = {
    Name  = "MyFirstServer-Terraform-Pratik"
    Owner = "Pratik Sontakke Tech"
  }

  # Simple user data to install a basic web server (optional)
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Pratik Sontakke Tech on EC2!</h1>" > /var/www/html/index.html
              EOF
}

# Output the Public IP of the EC2 instance
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.my_first_server.public_ip
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.my_first_server.id
}