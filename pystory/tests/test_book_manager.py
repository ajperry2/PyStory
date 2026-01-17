"""Tests for BookManager module."""

import pytest
from pystory.book_manager import BookManager


class TestBookManager:
    """Test cases for BookManager class."""

    def test_init(self):
        """Test BookManager initialization."""
        manager = BookManager(table_name="test-table", region="eu-west-1")
        assert manager.table.name == "test-table"
