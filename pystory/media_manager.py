"""
Media Manager Module

Handles uploading and managing images and videos in S3.
"""

import boto3
import logging
from typing import Optional, BinaryIO
from pathlib import Path


class MediaManager:
    """Manage story media files in S3."""

    def __init__(self, bucket_name: str, region: str = "us-east-1"):
        """
        Initialize the Media Manager.

        Args:
            bucket_name: Name of the S3 bucket
            region: AWS region
        """
        self.s3_client = boto3.client("s3", region_name=region)
        self.bucket_name = bucket_name
        self.logger = logging.getLogger(__name__)

    def upload_image(
        self, file_path: str, s3_key: str, metadata: Optional[dict] = None
    ) -> str:
        """
        Upload an image to S3.

        Args:
            file_path: Local path to the image file
            s3_key: S3 key (path) for the uploaded file
            metadata: Optional metadata for the file

        Returns:
            S3 URI of the uploaded file
        """
        self.logger.info(f"Uploading image {file_path} to s3://{self.bucket_name}/{s3_key}")

        extra_args = {"ContentType": "image/jpeg"}
        if metadata:
            extra_args["Metadata"] = metadata

        self.s3_client.upload_file(file_path, self.bucket_name, s3_key, ExtraArgs=extra_args)
        return f"s3://{self.bucket_name}/{s3_key}"

    def upload_video(
        self, file_path: str, s3_key: str, metadata: Optional[dict] = None
    ) -> str:
        """
        Upload a video to S3.

        Args:
            file_path: Local path to the video file
            s3_key: S3 key (path) for the uploaded file
            metadata: Optional metadata for the file

        Returns:
            S3 URI of the uploaded file
        """
        self.logger.info(f"Uploading video {file_path} to s3://{self.bucket_name}/{s3_key}")

        extra_args = {"ContentType": "video/mp4"}
        if metadata:
            extra_args["Metadata"] = metadata

        self.s3_client.upload_file(file_path, self.bucket_name, s3_key, ExtraArgs=extra_args)
        return f"s3://{self.bucket_name}/{s3_key}"

    def download_media(self, s3_key: str, local_path: str) -> str:
        """
        Download media from S3.

        Args:
            s3_key: S3 key of the file to download
            local_path: Local path to save the file

        Returns:
            Local file path
        """
        self.logger.info(f"Downloading s3://{self.bucket_name}/{s3_key} to {local_path}")
        self.s3_client.download_file(self.bucket_name, s3_key, local_path)
        return local_path

    def list_media(self, prefix: str = "") -> list:
        """
        List media files in S3.

        Args:
            prefix: S3 prefix to filter files

        Returns:
            List of S3 keys
        """
        self.logger.info(f"Listing media with prefix: {prefix}")
        response = self.s3_client.list_objects_v2(Bucket=self.bucket_name, Prefix=prefix)

        if "Contents" not in response:
            return []

        return [obj["Key"] for obj in response["Contents"]]

    def delete_media(self, s3_key: str) -> None:
        """
        Delete media from S3.

        Args:
            s3_key: S3 key of the file to delete
        """
        self.logger.info(f"Deleting s3://{self.bucket_name}/{s3_key}")
        self.s3_client.delete_object(Bucket=self.bucket_name, Key=s3_key)

    def generate_presigned_url(self, s3_key: str, expiration: int = 3600) -> str:
        """
        Generate a presigned URL for temporary access to media.

        Args:
            s3_key: S3 key of the file
            expiration: URL expiration time in seconds

        Returns:
            Presigned URL
        """
        url = self.s3_client.generate_presigned_url(
            "get_object",
            Params={"Bucket": self.bucket_name, "Key": s3_key},
            ExpiresIn=expiration,
        )
        return url
