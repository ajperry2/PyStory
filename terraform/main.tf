terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

import {
  to = aws_s3_bucket.story_media
  id = "pystory-media-bucket-unique-name"
}

# S3 bucket for storing images and videos
resource "aws_s3_bucket" "story_media" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "PyStory Media Bucket"
    Environment = var.environment
    Project     = "PyStory"
  }
}

resource "aws_s3_bucket_versioning" "story_media_versioning" {
  bucket = aws_s3_bucket.story_media.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "story_media_encryption" {
  bucket = aws_s3_bucket.story_media.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "story_media_public_access_block" {
  bucket = aws_s3_bucket.story_media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for book information
resource "aws_dynamodb_table" "books" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "book_id"
  range_key      = "created_at"

  attribute {
    name = "book_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "N"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "user_id"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  tags = {
    Name        = "PyStory Books Table"
    Environment = var.environment
    Project     = "PyStory"
  }
}

import {
  to = aws_iam_role.sagemaker_training_role
  id = "pystory-sagemaker-training-role"
}
# IAM role for SageMaker training jobs
resource "aws_iam_role" "sagemaker_training_role" {
  name = var.sagemaker_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "PyStory SageMaker Training Role"
    Environment = var.environment
    Project     = "PyStory"
  }
}

# IAM policy for SageMaker to access S3 bucket
resource "aws_iam_role_policy" "sagemaker_s3_policy" {
  name = "sagemaker-s3-access"
  role = aws_iam_role.sagemaker_training_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.story_media.arn,
          "${aws_s3_bucket.story_media.arn}/*"
        ]
      }
    ]
  })
}

# IAM policy for SageMaker to access DynamoDB
resource "aws_iam_role_policy" "sagemaker_dynamodb_policy" {
  name = "sagemaker-dynamodb-access"
  role = aws_iam_role.sagemaker_training_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.books.arn,
          "${aws_dynamodb_table.books.arn}/index/*"
        ]
      }
    ]
  })
}

# Attach AWS managed policy for SageMaker full access
resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
  role       = aws_iam_role.sagemaker_training_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}
import {
  to = aws_ecr_repository.pystory
  id = "pystory"
}
# ECR repository for Docker images
resource "aws_ecr_repository" "pystory" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "PyStory ECR Repository"
    Environment = var.environment
    Project     = "PyStory"
  }
}

# ECR lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "pystory_lifecycle" {
  repository = aws_ecr_repository.pystory.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
