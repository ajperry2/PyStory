"""Tests for StoryGenerator module."""

import pytest
from pystory.story_generator import StoryGenerator


class TestStoryGenerator:
    """Test cases for StoryGenerator class."""

    def test_init(self):
        """Test StoryGenerator initialization."""
        generator = StoryGenerator(
            sagemaker_role_arn="arn:aws:iam::123456789:role/test-role",
            region="us-east-1"
        )
        assert generator.sagemaker_role_arn == "arn:aws:iam::123456789:role/test-role"

    def test_generate_story(self):
        """Test story generation."""
        generator = StoryGenerator(
            sagemaker_role_arn="arn:aws:iam::123456789:role/test-role"
        )
        story = generator.generate_story("Once upon a time")
        assert "Generated story" in story
        assert "Once upon a time" in story
