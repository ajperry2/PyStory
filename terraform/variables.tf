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

variable "google_client_id" {
  description = "Google OAuth client ID for authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth client secret for authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cognito_domain" {
  description = "Domain prefix for Cognito hosted UI"
  type        = string
  default     = "pystory-auth"
}

variable "cognito_callback_urls" {
  description = "Allowed callback URLs for Cognito"
  type        = list(string)
  default     = ["http://localhost:3000/callback", "https://localhost:3000/callback"]
}

variable "cognito_logout_urls" {
  description = "Allowed logout URLs for Cognito"
  type        = list(string)
  default     = ["http://localhost:3000/", "https://localhost:3000/"]
}
