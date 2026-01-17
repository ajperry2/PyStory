"""
Main entry point for the PyStory package.
"""

import logging
import sys


def main():
    """Main entry point for PyStory application."""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )
    
    logger = logging.getLogger(__name__)
    logger.info("PyStory package initialized")
    logger.info("Use the PyStory API to generate and manage children's stories")
    
    # Display available modules
    print("PyStory - Generate and Publish Visualizations of Children Stories")
    print("\nAvailable modules:")
    print("  - StoryGenerator: Generate stories using SageMaker")
    print("  - MediaManager: Manage images and videos in S3")
    print("  - BookManager: Manage book information in DynamoDB")
    print("\nFor usage examples, see the README.md file")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
