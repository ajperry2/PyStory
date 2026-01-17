output "s3_bucket_name" {
  description = "Name of the S3 bucket for story media"
  value       = aws_s3_bucket.story_media.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for story media"
  value       = aws_s3_bucket.story_media.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for books"
  value       = aws_dynamodb_table.books.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for books"
  value       = aws_dynamodb_table.books.arn
}

output "sagemaker_role_arn" {
  description = "ARN of the SageMaker training role"
  value       = aws_iam_role.sagemaker_training_role.arn
}

output "sagemaker_role_name" {
  description = "Name of the SageMaker training role"
  value       = aws_iam_role.sagemaker_training_role.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.pystory.repository_url
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = aws_ecr_repository.pystory.arn
}
