#!/bin/bash

set -e

# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

APP_NAME="three-tier-app"
APP_PORT="3001"

HEALTH_URL="http://localhost:${APP_PORT}/"


# ---------------------------------------------------------
# Check Docker service
# ---------------------------------------------------------

echo "Checking Docker service..."

if systemctl is-active --quiet docker; then
    echo "PASS: Docker service is running."
else
    echo "FAIL: Docker service is not running."
    exit 1
fi


# ---------------------------------------------------------
# Check application container
# ---------------------------------------------------------

echo "Checking application container..."

if docker ps --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
    echo "PASS: Application container is running."
else
    echo "FAIL: Application container is not running."

    echo ""
    echo "Available containers:"
    docker ps -a || true

    exit 1
fi


# ---------------------------------------------------------
# Check application HTTP endpoint
# ---------------------------------------------------------

echo "Checking application HTTP endpoint..."

HTTP_STATUS=$(curl \
    --silent \
    --output /dev/null \
    --write-out "%{http_code}" \
    --max-time 10 \
    "$HEALTH_URL" || true)


if [ "$HTTP_STATUS" = "200" ]; then
    echo "PASS: Application returned HTTP 200."
else
    echo "FAIL: Application returned HTTP status: ${HTTP_STATUS}"
    exit 1
fi


# ---------------------------------------------------------
# Display container status
# ---------------------------------------------------------

echo ""
echo "Container status:"
docker ps \
    --filter "name=${APP_NAME}" \
    --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"


echo ""
echo "========================================="
echo "Health check completed successfully"
echo "========================================="
