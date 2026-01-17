# PyStory
Generate and Publish Visualizations of Children Stories for Youtube

## Overview

PyStory is a monorepo project that combines Python application code with Terraform infrastructure for creating, managing, and publishing children's stories with visualizations for YouTube content.

## Project Structure

```
PyStory/
├── .github/
│   └── workflows/
│       └── docker-build-push.yml    # CI/CD pipeline for Docker builds
├── terraform/                        # Infrastructure as Code
│   ├── main.tf                       # Main Terraform configuration
│   ├── variables.tf                  # Variable definitions
│   ├── outputs.tf                    # Output definitions
│   └── terraform.tfvars.example      # Example variables file
├── pystory/                          # Python package
│   ├── __init__.py
│   ├── story_generator.py            # SageMaker story generation
│   ├── media_manager.py              # S3 media management
│   └── book_manager.py               # DynamoDB book management
├── Dockerfile                        # Docker configuration
├── pyproject.toml                    # Python project configuration
├── requirements.txt                  # Python dependencies
└── README.md                         # This file
```

## Infrastructure

The Terraform configuration provisions the following AWS resources:

### 1. S3 Bucket for Media Storage
- Stores images and videos of stories
- Versioning enabled
- Server-side encryption (AES256)
- Public access blocked by default

### 2. DynamoDB Table for Book Information
- Stores book metadata and information
- Pay-per-request billing mode
- Global Secondary Index on user_id
- Automatic scaling

### 3. IAM Role for SageMaker
- Allows launching SageMaker training jobs
- Configurable hardware (instance types)
- Access to S3 bucket and DynamoDB table
- Full SageMaker permissions

### 4. Amazon ECR Repository
- Docker image registry
- Automatic image scanning
- Lifecycle policies for image management

## Setup Instructions

### Prerequisites
- AWS account with appropriate permissions
- Terraform >= 1.0
- Python >= 3.8
- Docker
- AWS CLI configured

### 1. Deploy Infrastructure

```bash
cd terraform

# Copy and edit the example variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Apply the infrastructure
terraform apply
```

### 2. Install Python Package

```bash
# Install in development mode
pip install -e .

# Or install with dev dependencies
pip install -e ".[dev]"
```

### 3. Set Up GitHub Secrets

For the CI/CD pipeline to work, configure the following secrets in your GitHub repository:

- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `TF_VAR_S3_BUCKET_NAME`: Unique S3 bucket name for the PyStory media storage

Navigate to: Repository Settings → Secrets and variables → Actions → New repository secret

## Python Package Usage

### Story Generator

```python
from pystory import StoryGenerator

# Initialize with SageMaker role ARN (from Terraform output)
generator = StoryGenerator(
    sagemaker_role_arn="arn:aws:iam::account:role/pystory-sagemaker-training-role",
    region="us-east-1"
)

# Create a training job
response = generator.create_training_job(
    job_name="my-story-training-job",
    training_image="123456789.dkr.ecr.us-east-1.amazonaws.com/pystory:latest",
    instance_type="ml.m5.xlarge",
    input_data_s3_path="s3://my-bucket/training-data/",
    output_data_s3_path="s3://my-bucket/output/"
)
```

### Media Manager

```python
from pystory import MediaManager

# Initialize with S3 bucket name (from Terraform output)
media = MediaManager(bucket_name="pystory-media-bucket", region="us-east-1")

# Upload an image
image_uri = media.upload_image(
    file_path="/path/to/image.jpg",
    s3_key="stories/story-1/image-1.jpg",
    metadata={"story_id": "story-1"}
)

# Upload a video
video_uri = media.upload_video(
    file_path="/path/to/video.mp4",
    s3_key="stories/story-1/video-1.mp4"
)

# Generate presigned URL for temporary access
url = media.generate_presigned_url("stories/story-1/image-1.jpg", expiration=3600)
```

### Book Manager

```python
from pystory import BookManager

# Initialize with DynamoDB table name (from Terraform output)
books = BookManager(table_name="pystory-books", region="us-east-1")

# Create a new book
book = books.create_book(
    book_id="book-123",
    user_id="user-456",
    title="The Adventures of Sunny",
    description="A story about a brave little sun",
    media_urls=["s3://bucket/stories/story-1/image-1.jpg"]
)

# Get a book
book = books.get_book(book_id="book-123", created_at=1234567890)

# List books by user
user_books = books.list_books_by_user(user_id="user-456")

# Publish a book
books.publish_book(book_id="book-123", created_at=1234567890)
```

## CI/CD Pipeline

The GitHub Actions workflow automatically:

1. Triggers on pushes to `main` or `develop` branches
2. Authenticates with AWS using GitHub secrets
3. Applies Terraform infrastructure changes
4. Builds the Docker image
5. Pushes the image to Amazon ECR with appropriate tags
6. Uses Docker layer caching for faster builds

### Image Tagging Strategy

- `latest`: Latest build from main branch
- `<branch>`: Branch name (e.g., `main`, `develop`)
- `<branch>-<sha>`: Branch with commit SHA (e.g., `main-abc1234`)
- `pr-<number>`: Pull request number

## Development

### Running Tests

```bash
# Install dev dependencies
pip install -r requirements-dev.txt

# Run tests
pytest

# Run tests with coverage
pytest --cov=pystory --cov-report=html
```

### Code Formatting

```bash
# Format code with black
black pystory/

# Check code style with flake8
flake8 pystory/

# Type checking with mypy
mypy pystory/
```

### Building Docker Image Locally

```bash
# Build the image
docker build -t pystory:local .

# Run the container
docker run pystory:local
```

## Terraform Outputs

After applying the Terraform configuration, you can retrieve important values:

```bash
cd terraform

# Get all outputs
terraform output

# Get specific output
terraform output ecr_repository_url
terraform output s3_bucket_name
terraform output dynamodb_table_name
terraform output sagemaker_role_arn
```

## Security Considerations

- S3 bucket has public access blocked by default
- Server-side encryption enabled for S3
- ECR images are scanned on push
- IAM roles follow principle of least privilege
- Sensitive Terraform variables marked as sensitive
- Docker image runs as non-root user

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

