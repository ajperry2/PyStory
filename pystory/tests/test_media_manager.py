"""Tests for MediaManager module."""

import pytest
from pystory.media_manager import MediaManager


class TestMediaManager:
    """Test cases for MediaManager class."""

    def test_init(self):
        """Test MediaManager initialization."""
        manager = MediaManager(bucket_name="test-bucket", region="us-west-2")
        assert manager.bucket_name == "test-bucket"
