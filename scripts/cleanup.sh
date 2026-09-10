#!/bin/bash

set -e

APP_NAME="three-tier-app"
APP_DIR="/opt/${APP_NAME}"


echo "========================================="
echo "Starting application cleanup"
echo "========================================="


# ---------------------------------------------------------
# Stop application container
# ---------------------------------------------------------

if docker ps --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then

    echo "Stopping application container..."

    docker stop "$APP_NAME"

else

    echo "Application container is not currently running."

fi


# ---------------------------------------------------------
# Remove application container
# ---------------------------------------------------------

if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then

    echo "Removing application container..."

    docker rm "$APP_NAME"

else

    echo "Application container does not exist."

fi


# ---------------------------------------------------------
# Remove application directory
# ---------------------------------------------------------

if [ -d "$APP_DIR" ]; then

    echo "Removing application files..."

    rm -rf "$APP_DIR"

else

    echo "Application directory does not exist."

fi


# ---------------------------------------------------------
# Remove unused Docker resources
# ---------------------------------------------------------

echo "Cleaning unused Docker resources..."

docker image prune -f || true
docker container prune -f || true


echo ""
echo "========================================="
echo "Application cleanup completed"
echo "========================================="
