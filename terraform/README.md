# PyStory Infrastructure

This directory contains Terraform configuration for provisioning PyStory infrastructure on AWS.

## Resources Provisioned

1. **S3 Bucket** - For storing story images and videos
2. **DynamoDB Table** - For storing book information
3. **IAM Role** - For SageMaker training jobs with configurable hardware
4. **ECR Repository** - For Docker images

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS account with permissions to create the above resources

## Quick Start

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your desired configuration:
   ```hcl
   aws_region          = "us-east-1"
   environment         = "dev"
   s3_bucket_name      = "my-unique-pystory-bucket"
   dynamodb_table_name = "pystory-books"
   ecr_repository_name = "pystory"
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Preview the changes:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration Variables

### Required Variables

- `s3_bucket_name` - Name of the S3 bucket (must be globally unique)

### Optional Variables

- `aws_region` - AWS region (default: `us-east-1`)
- `environment` - Environment name (default: `dev`)
- `dynamodb_table_name` - DynamoDB table name (default: `pystory-books`)
- `sagemaker_role_name` - IAM role name for SageMaker (default: `pystory-sagemaker-training-role`)
- `ecr_repository_name` - ECR repository name (default: `pystory`)

## Outputs

After applying, Terraform will output important values:

```bash
# View all outputs
terraform output

# View specific output
terraform output ecr_repository_url
```

Available outputs:
- `s3_bucket_name` - Name of the S3 bucket
- `s3_bucket_arn` - ARN of the S3 bucket
- `dynamodb_table_name` - Name of the DynamoDB table
- `dynamodb_table_arn` - ARN of the DynamoDB table
- `sagemaker_role_arn` - ARN of the SageMaker IAM role
- `sagemaker_role_name` - Name of the SageMaker IAM role
- `ecr_repository_url` - URL of the ECR repository
- `ecr_repository_arn` - ARN of the ECR repository

## SageMaker Instance Types

The IAM role supports various SageMaker instance types. Configure the instance type when creating training jobs:

- `ml.t3.medium` - General purpose (testing)
- `ml.m5.xlarge` - General purpose (production)
- `ml.p3.2xlarge` - GPU instance (deep learning)
- `ml.p3.8xlarge` - GPU instance (large-scale training)

See [AWS SageMaker Pricing](https://aws.amazon.com/sagemaker/pricing/) for more options.

## State Management

This configuration uses local state by default. For production use, consider:

1. Using remote state with S3 backend:
   ```hcl
   terraform {
     backend "s3" {
       bucket = "my-terraform-state-bucket"
       key    = "pystory/terraform.tfstate"
       region = "us-east-1"
     }
   }
   ```

2. Enable state locking with DynamoDB

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all resources, including the S3 bucket and DynamoDB table. Ensure you have backups of any important data.

## Security Best Practices

1. Never commit `terraform.tfvars` with sensitive data
2. Use AWS Secrets Manager for sensitive credentials in production
3. Enable CloudTrail for audit logging
4. Use VPC endpoints for private connectivity
5. Regularly rotate AWS access keys
6. Enable MFA for AWS account access

## Troubleshooting

### S3 Bucket Name Already Exists

S3 bucket names must be globally unique. Try a different name in `terraform.tfvars`.

### Insufficient Permissions

Ensure your AWS credentials have permissions to create:
- S3 buckets
- DynamoDB tables
- IAM roles and policies
- Cognito user pools
- ECR repositories

### Google OAuth Not Working

1. Verify the Google Client ID and Secret are correct
2. Check that redirect URIs are properly configured in Google Cloud Console
3. Ensure the Google+ API is enabled

## Support

For issues or questions, please open an issue in the GitHub repository.
