# main.tf

provider "aws" {
  region = "ap-south-1" # Mumbai Region
}

# 1. Create an S3 Bucket (Your "Digital Locker")
resource "aws_s3_bucket" "my_digital_locker" {
  # Bucket names must be globally unique
  bucket = "pratik-digital-locker-demo-${random_id.bucket_suffix.hex}" # Append random string for uniqueness

  # ACL (Access Control List) - "private" means only owner can access by default.
  # For more granular control, Bucket Policies and IAM are preferred over ACLs for new buckets.
  # acl = "private" # This is often the default, but explicit can be good.
  # Modern best practice is to use aws_s3_bucket_public_access_block

  tags = {
    Name  = "MyDigitalLocker-Pratik"
    Owner = "Pratik Sontakke Tech"
  }
}

# Resource to generate a random suffix for the bucket name to help ensure uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 2. Block Public Access settings for the S3 Bucket (Recommended for most use cases)
resource "aws_s3_bucket_public_access_block" "locker_public_access_block" {
  bucket = aws_s3_bucket.my_digital_locker.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Upload a sample file (Object) to the S3 Bucket
resource "aws_s3_object" "my_sample_file" {
  bucket = aws_s3_bucket.my_digital_locker.id
  key    = "documents/my_important_note.txt" # The "path" or name of the object in the bucket
  source = "my_important_note.txt"           # Path to a local file to upload
  # content_type = "text/plain" # Optional: S3 often infers this

  # To make this object publicly readable (use with caution!):
  # acl    = "public-read"
  # Ensure your aws_s3_bucket_public_access_block settings allow this if you uncomment.

  tags = {
    Name = "SampleNoteFile"
  }

  # Ensure the local file exists before running terraform apply
  # You can create a dummy file: `echo "Hello from Pratik's S3 Locker!" > my_important_note.txt`
}

# Output the S3 Bucket Name
output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.my_digital_locker.bucket
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket (useful for website hosting, etc.)"
  value       = aws_s3_bucket.my_digital_locker.bucket_domain_name
}

output "sample_file_s3_uri" {
  description = "S3 URI of the uploaded sample file"
  value       = "s3://${aws_s3_bucket.my_digital_locker.bucket}/${aws_s3_object.my_sample_file.key}"
}