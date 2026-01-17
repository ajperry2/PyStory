# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the Python package
COPY pystory/ ./pystory/
COPY pyproject.toml .
COPY README.md .

# Install the package
RUN pip install --no-cache-dir -e .

# Create a non-root user
RUN useradd -m -u 1000 pystory && \
    chown -R pystory:pystory /app

USER pystory

# Set the entrypoint
CMD ["python", "-m", "pystory"]
