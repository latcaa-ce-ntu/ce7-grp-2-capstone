# Create S3 bucket for load balancer logs
resource "aws_s3_bucket" "lb_logs" {
  bucket        = "${var.name_prefix}-alb-logs"
  force_destroy = true # Allows bucket deletion even when it contains objects

  tags = {
    Name = "${var.name_prefix}-alb-logs"
  }
}

# Block all public access to the bucket for security 
resource "aws_s3_bucket_public_access_block" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  block_public_acls       = true # Prevent public ACLs
  block_public_policy     = true # Prevent public bucket policies  
  ignore_public_acls      = true # Ignore any public ACLs
  restrict_public_buckets = true # Restrict public bucket access
}

# Enable server-side encryption for all objects
resource "aws_s3_bucket_server_side_encryption_configuration" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Use AES-256 encryption
    }
  }
}

# Enable versioning to maintain log history
resource "aws_s3_bucket_versioning" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Configure bucket policy to allow ALB to write logs
resource "aws_s3_bucket_policy" "lb_logs" {
  bucket = aws_s3_bucket.lb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::127311923021:root" # AWS ALB service account for us-east-1
        }
        Action = [
          "s3:PutObject" # Allow writing objects (logs)
        ]
        Resource = "${aws_s3_bucket.lb_logs.arn}/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com" # ALB log delivery service
        }
        Action = [
          "s3:PutObject" # Allow writing objects (logs)
        ]
        Resource = "${aws_s3_bucket.lb_logs.arn}/*"
      }
    ]
  })
}