"""
PyStory - Generate and Publish Visualizations of Children Stories for Youtube

This package provides functionality for creating, managing, and publishing
children's stories with visualizations for YouTube content.
"""

__version__ = "0.1.0"
__author__ = "PyStory Team"

from .story_generator import StoryGenerator
from .media_manager import MediaManager
from .book_manager import BookManager

__all__ = ["StoryGenerator", "MediaManager", "BookManager"]
