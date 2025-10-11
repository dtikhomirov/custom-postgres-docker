#!/bin/bash

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  export $(cat .env | grep -v '^#' | xargs)
fi

# Stop and remove the Docker containers
echo "Stopping and removing Docker containers..."
docker-compose down

# Remove the Docker images
echo "Removing Docker images..."
docker rmi custom-postgres:latest || true

# Optionally, remove any dangling images
echo "Removing dangling images..."
docker image prune -f

# Optionally, remove any stopped containers
echo "Removing stopped containers..."
docker container prune -f

# Optionally, remove any unused volumes
echo "Removing unused volumes..."
docker volume prune -f

# Ask user if they want to remove the data directory
if [ -n "$POSTGRES_DATA_PATH" ] && [ -d "$POSTGRES_DATA_PATH" ]; then
  echo ""
  read -p "Do you want to remove the PostgreSQL data directory ($POSTGRES_DATA_PATH)? [y/N]: " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Removing PostgreSQL data directory: $POSTGRES_DATA_PATH"
    rm -rf "$POSTGRES_DATA_PATH"
  else
    echo "Keeping PostgreSQL data directory: $POSTGRES_DATA_PATH"
  fi
fi

echo "✅ Cleanup completed."