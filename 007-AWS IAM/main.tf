# main.tf

provider "aws" {
  region = "ap-south-1" # Or your preferred region
}

# -- IAM User, Group, and Policy for S3 Read-Only --

# 1. Create an IAM User for a developer
resource "aws_iam_user" "developer_rahul" {
  name = "dev-rahul"
  path = "/developers/"

  tags = {
    Description = "Developer Rahul for Project Alpha"
  }
}

# 2. Create an IAM Group for Developers
resource "aws_iam_group" "developers_group" {
  name = "Developers"
  path = "/departments/"
}

# 3. Add the user to the group
resource "aws_iam_user_group_membership" "rahul_in_developers" {
  user = aws_iam_user.developer_rahul.name
  groups = [
    aws_iam_group.developers_group.name,
  ]
}

# 4. Define an IAM Policy for S3 Read-Only access to a specific bucket (replace BUCKET_NAME)
# For demo, we'll use a general S3 read-only. For specific bucket, adjust Resource.
data "aws_caller_identity" "current" {} # To get account ID
locals {
  s3_bucket_name_for_policy = "pratik-demo-bucket-${data.aws_caller_identity.current.account_id}" # Example bucket name
}

resource "aws_iam_policy" "s3_readonly_specific_bucket_policy" {
  name        = "S3ReadOnlyFor${replace(title(local.s3_bucket_name_for_policy), "-", "")}"
  description = "Allows read-only access to a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${local.s3_bucket_name_for_policy}",
          "arn:aws:s3:::${local.s3_bucket_name_for_policy}/*"
        ]
      },
      { # Allows listing all buckets (needed for console experience sometimes, optional)
        Effect   = "Allow",
        Action   = "s3:ListAllMyBuckets",
        Resource = "*"
      }
    ]
  })
}

# 5. Attach the policy to the Developers group
resource "aws_iam_group_policy_attachment" "developers_s3_readonly_attachment" {
  group      = aws_iam_group.developers_group.name
  policy_arn = aws_iam_policy.s3_readonly_specific_bucket_policy.arn
}


# -- IAM Role for EC2 to Access S3 --

# 6. Create an IAM Role that EC2 instances can assume
resource "aws_iam_role" "ec2_s3_access_role" {
  name = "EC2S3AccessRole"
  path = "/service-roles/"

  # Trust policy: Allows EC2 service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Description = "Role for EC2 instances to access S3"
  }
}

# 7. Attach a managed policy (e.g., AmazonS3ReadOnlyAccess) to the role
# Or you could attach the custom policy created above if its permissions are suitable.
resource "aws_iam_role_policy_attachment" "ec2_s3_readonly_attachment" {
  role       = aws_iam_role.ec2_s3_access_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" # AWS Managed Policy
  # Or use: policy_arn = aws_iam_policy.s3_readonly_specific_bucket_policy.arn
}

# 8. Create an Instance Profile to attach the role to EC2 instances
resource "aws_iam_instance_profile" "ec2_s3_instance_profile" {
  name = "EC2S3AccessInstanceProfile"
  role = aws_iam_role.ec2_s3_access_role.name

  tags = {
    Description = "Instance profile for EC2 S3 access"
  }
}

# Outputs
output "developer_rahul_arn" {
  value = aws_iam_user.developer_rahul.arn
}

output "developers_group_arn" {
  value = aws_iam_group.developers_group.arn
}

output "s3_readonly_policy_arn" {
  value = aws_iam_policy.s3_readonly_specific_bucket_policy.arn
}

output "ec2_s3_access_role_arn" {
  value = aws_iam_role.ec2_s3_access_role.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_s3_instance_profile.name
}