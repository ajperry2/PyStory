variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for storing images and videos"
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for book information"
  type        = string
  default     = "pystory-books"
}

variable "sagemaker_role_name" {
  description = "Name of the IAM role for SageMaker training jobs"
  type        = string
  default     = "pystory-sagemaker-training-role"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "pystory"
}
