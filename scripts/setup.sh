#!/bin/bash

set -e  # Exit on any error

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  echo "Loading environment variables from .env file..."
  export $(cat .env | grep -v '^#' | xargs)
else
  echo "Warning: .env file not found. Please copy .env.example to .env and configure your settings."
  exit 1
fi

# Check if POSTGRES_DATA_PATH is set
if [ -z "$POSTGRES_DATA_PATH" ]; then
  echo "Error: POSTGRES_DATA_PATH environment variable is not set."
  echo "Please set it in your .env file."
  exit 1
fi

# Check if the parent directory exists, create if it doesn't
PARENT_DIR=$(dirname "$POSTGRES_DATA_PATH")
if [ ! -d "$PARENT_DIR" ]; then
  echo "Creating parent directory: $PARENT_DIR"
  mkdir -p "$PARENT_DIR"
fi

# Check if the data path exists, create if it doesn't
if [ ! -d "$POSTGRES_DATA_PATH" ]; then
  echo "Creating PostgreSQL data directory: $POSTGRES_DATA_PATH"
  mkdir -p "$POSTGRES_DATA_PATH"
else
  echo "Using existing PostgreSQL data directory: $POSTGRES_DATA_PATH"
fi

# Verify the path is writable
if [ ! -w "$POSTGRES_DATA_PATH" ]; then
  echo "Error: PostgreSQL data directory is not writable: $POSTGRES_DATA_PATH"
  echo "Please check permissions."
  exit 1
fi

echo "PostgreSQL data path validated: $POSTGRES_DATA_PATH"

# Build the Docker image
echo "Building Docker image..."
docker-compose build

# Start the Docker containers
echo "Starting Docker containers..."
docker-compose up -d

# Wait for Postgres to start
echo "Waiting for Postgres to start..."
sleep 10

# Check if the container is running
if docker-compose ps | grep -q "Up"; then
  echo "✅ Postgres setup complete. You can now connect to the database."
  echo "Connection details:"
  echo "  Host: localhost"
  echo "  Port: ${POSTGRES_PORT:-5432}"
  echo "  Database: ${POSTGRES_DB:-mydatabase}"
  echo "  User: ${POSTGRES_USER:-postgres}"
else
  echo "❌ Error: Postgres container failed to start. Check logs with 'docker-compose logs'"
  exit 1
fi

# Check installed extensions
echo "Checking installed extensions..."
if docker exec ${CONTAINER_NAME} psql -U root -d root -c "SELECT extname, extversion FROM pg_extension;"; then
  echo "✅ Extensions query executed successfully"
else
  echo "❌ Error: Failed to query extensions. Check database connection and permissions."
  exit 1
fi