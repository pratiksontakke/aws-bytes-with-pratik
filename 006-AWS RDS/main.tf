# main.tf

provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

# For storing the DB password securely (recommended for actual use)
# resource "random_password" "db_password" {
#   length           = 16
#   special          = true
#   override_special = "_%@"
# }

# For demo simplicity, we might hardcode or use a variable.
# In a real scenario, consider AWS Secrets Manager.

# Assuming you have a default VPC or existing VPC and subnets.
# For RDS, you often need a DB Subnet Group.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "swadisht-sweets-subnet-group"
  subnet_ids = data.aws_subnets.default.ids # Using default VPC subnets for simplicity

  tags = {
    Name = "SwadishtSweets-SubnetGroup"
  }
}

# Security Group for RDS instance
resource "aws_security_group" "rds_sg" {
  name        = "swadisht-sweets-rds-sg"
  description = "Allow DB traffic"
  vpc_id      = data.aws_vpc.default.id # Using default VPC

  # Ingress rule to allow traffic from your IP (replace with actual IP/range)
  # Or from an EC2 instance's security group if your app server is in EC2
  ingress {
    from_port   = 3306 # MySQL port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For demo only. Restrict to your IP/SG in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SwadishtSweets-RDSSG"
  }
}

# Create an RDS Instance for "Swadisht Sweets"
resource "aws_db_instance" "swadisht_sweets_db" {
  identifier             = "swadisht-sweets-db-tf"
  allocated_storage      = 20 # In GB
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0" # Check for latest supported versions
  instance_class         = "db.t3.micro" # Free tier eligible (check current eligibility)
  username               = "mrsharma"
  password               = "pratik123" # REPLACE with a strong password or use random_password.value
  # parameter_group_name = "default.mysql8.0" # Or a custom one
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot    = true # For demo, set to false for production
  publicly_accessible  = true # For demo to connect easily. Set to false for production.
  # multi_az             = false # For Dev/Test. Set to true for Production for High Availability.

  tags = {
    Name  = "SwadishtSweetsDB-Terraform"
    Owner = "Pratik Sontakke Tech"
    App   = "Swadisht Sweets Online"
  }
}

output "rds_instance_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.swadisht_sweets_db.endpoint
}

output "rds_instance_port" {
  description = "The port for the RDS instance"
  value       = aws_db_instance.swadisht_sweets_db.port
}

# mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p
