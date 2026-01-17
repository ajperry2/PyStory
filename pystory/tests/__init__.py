"""Tests for PyStory package."""

import pytest
from pystory import __version__


def test_version():
    """Test that version is defined."""
    assert __version__ == "0.1.0"


def test_imports():
    """Test that main classes can be imported."""
    from pystory import StoryGenerator, MediaManager, BookManager
    
    assert StoryGenerator is not None
    assert MediaManager is not None
    assert BookManager is not None
