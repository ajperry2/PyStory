"""
Story Generator Module

Handles the generation of children's stories using AI models
and manages the SageMaker training jobs.
"""

import boto3
import logging
from typing import Dict, Any, Optional


class StoryGenerator:
    """Generate children's stories using SageMaker."""

    def __init__(self, sagemaker_role_arn: str, region: str = "us-east-1"):
        """
        Initialize the Story Generator.

        Args:
            sagemaker_role_arn: ARN of the IAM role for SageMaker
            region: AWS region
        """
        self.sagemaker_client = boto3.client("sagemaker", region_name=region)
        self.sagemaker_role_arn = sagemaker_role_arn
        self.logger = logging.getLogger(__name__)

    def create_training_job(
        self,
        job_name: str,
        training_image: str,
        instance_type: str = "ml.m5.xlarge",
        instance_count: int = 1,
        input_data_s3_path: str = None,
        output_data_s3_path: str = None,
        hyperparameters: Optional[Dict[str, str]] = None,
    ) -> Dict[str, Any]:
        """
        Create a SageMaker training job for story generation.

        Args:
            job_name: Name of the training job
            training_image: ECR image URI for training
            instance_type: Type of instance for training
            instance_count: Number of instances
            input_data_s3_path: S3 path for input data
            output_data_s3_path: S3 path for output data
            hyperparameters: Training hyperparameters

        Returns:
            Response from SageMaker CreateTrainingJob API
        """
        self.logger.info(f"Creating training job: {job_name}")

        training_params = {
            "TrainingJobName": job_name,
            "RoleArn": self.sagemaker_role_arn,
            "AlgorithmSpecification": {
                "TrainingImage": training_image,
                "TrainingInputMode": "File",
            },
            "ResourceConfig": {
                "InstanceType": instance_type,
                "InstanceCount": instance_count,
                "VolumeSizeInGB": 30,
            },
            "StoppingCondition": {"MaxRuntimeInSeconds": 86400},
            "OutputDataConfig": {"S3OutputPath": output_data_s3_path or "s3://default"},
        }

        if hyperparameters:
            training_params["HyperParameters"] = hyperparameters

        if input_data_s3_path:
            training_params["InputDataConfig"] = [
                {
                    "ChannelName": "training",
                    "DataSource": {
                        "S3DataSource": {
                            "S3DataType": "S3Prefix",
                            "S3Uri": input_data_s3_path,
                            "S3DataDistributionType": "FullyReplicated",
                        }
                    },
                }
            ]

        response = self.sagemaker_client.create_training_job(**training_params)
        return response

    def describe_training_job(self, job_name: str) -> Dict[str, Any]:
        """
        Get the status of a training job.

        Args:
            job_name: Name of the training job

        Returns:
            Training job description
        """
        return self.sagemaker_client.describe_training_job(TrainingJobName=job_name)

    def generate_story(self, prompt: str, **kwargs) -> str:
        """
        Generate a story based on a prompt.

        Args:
            prompt: Story generation prompt
            **kwargs: Additional parameters

        Returns:
            Generated story text
        """
        # Placeholder for story generation logic
        self.logger.info(f"Generating story with prompt: {prompt}")
        return f"Generated story based on: {prompt}"
