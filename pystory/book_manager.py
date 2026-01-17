"""
Book Manager Module

Handles book information storage and retrieval in DynamoDB.
"""

import boto3
import logging
import time
from typing import Dict, Any, List, Optional
from decimal import Decimal


class BookManager:
    """Manage book information in DynamoDB."""

    def __init__(self, table_name: str, region: str = "us-east-1"):
        """
        Initialize the Book Manager.

        Args:
            table_name: Name of the DynamoDB table
            region: AWS region
        """
        self.dynamodb = boto3.resource("dynamodb", region_name=region)
        self.table = self.dynamodb.Table(table_name)
        self.logger = logging.getLogger(__name__)

    def create_book(
        self,
        book_id: str,
        user_id: str,
        title: str,
        description: str,
        media_urls: Optional[List[str]] = None,
        metadata: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """
        Create a new book entry.

        Args:
            book_id: Unique book identifier
            user_id: User who created the book
            title: Book title
            description: Book description
            media_urls: List of S3 URLs for media
            metadata: Additional book metadata

        Returns:
            Created book item
        """
        self.logger.info(f"Creating book: {book_id}")

        created_at = int(time.time())
        item = {
            "book_id": book_id,
            "user_id": user_id,
            "created_at": created_at,
            "updated_at": created_at,
            "title": title,
            "description": description,
            "status": "draft",
        }

        if media_urls:
            item["media_urls"] = media_urls

        if metadata:
            item["metadata"] = metadata

        self.table.put_item(Item=item)
        return item

    def get_book(self, book_id: str, created_at: int) -> Optional[Dict[str, Any]]:
        """
        Retrieve a book by ID.

        Args:
            book_id: Book identifier
            created_at: Creation timestamp

        Returns:
            Book item or None if not found
        """
        self.logger.info(f"Getting book: {book_id}")

        response = self.table.get_item(Key={"book_id": book_id, "created_at": created_at})
        return response.get("Item")

    def update_book(
        self, book_id: str, created_at: int, updates: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Update a book entry.

        Args:
            book_id: Book identifier
            created_at: Creation timestamp
            updates: Fields to update

        Returns:
            Updated book item
        """
        self.logger.info(f"Updating book: {book_id}")

        update_expression_parts = []
        expression_attribute_names = {}
        expression_attribute_values = {}

        updates["updated_at"] = int(time.time())

        for i, (key, value) in enumerate(updates.items()):
            placeholder_name = f"#attr{i}"
            placeholder_value = f":val{i}"
            update_expression_parts.append(f"{placeholder_name} = {placeholder_value}")
            expression_attribute_names[placeholder_name] = key
            expression_attribute_values[placeholder_value] = value

        update_expression = "SET " + ", ".join(update_expression_parts)

        response = self.table.update_item(
            Key={"book_id": book_id, "created_at": created_at},
            UpdateExpression=update_expression,
            ExpressionAttributeNames=expression_attribute_names,
            ExpressionAttributeValues=expression_attribute_values,
            ReturnValues="ALL_NEW",
        )

        return response.get("Attributes")

    def delete_book(self, book_id: str, created_at: int) -> None:
        """
        Delete a book entry.

        Args:
            book_id: Book identifier
            created_at: Creation timestamp
        """
        self.logger.info(f"Deleting book: {book_id}")
        self.table.delete_item(Key={"book_id": book_id, "created_at": created_at})

    def list_books_by_user(self, user_id: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        List all books for a user.

        Args:
            user_id: User identifier
            limit: Maximum number of books to return

        Returns:
            List of book items
        """
        self.logger.info(f"Listing books for user: {user_id}")

        response = self.table.query(
            IndexName="UserIdIndex",
            KeyConditionExpression="user_id = :uid",
            ExpressionAttributeValues={":uid": user_id},
            Limit=limit,
            ScanIndexForward=False,  # Sort by created_at descending
        )

        return response.get("Items", [])

    def publish_book(self, book_id: str, created_at: int) -> Dict[str, Any]:
        """
        Mark a book as published.

        Args:
            book_id: Book identifier
            created_at: Creation timestamp

        Returns:
            Updated book item
        """
        self.logger.info(f"Publishing book: {book_id}")
        return self.update_book(
            book_id, created_at, {"status": "published", "published_at": int(time.time())}
        )
