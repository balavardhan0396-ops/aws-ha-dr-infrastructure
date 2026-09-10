#!/bin/bash

set -e

echo "========================================="
echo "Starting application installation"
echo "========================================="

# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

APP_NAME="three-tier-app"
APP_PORT="3001"

AWS_REGION="${AWS_REGION:-eu-north-1}"

# These values can be supplied through environment variables
# by Terraform/user-data.
DB_SECRET_ARN="${DB_SECRET_ARN:-}"
DB_HOST="${DB_HOST:-}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-appdb}"

# Docker image to deploy.
# Example:
# 123456789012.dkr.ecr.eu-north-1.amazonaws.com/three-tier-app:latest
APP_IMAGE="${APP_IMAGE:-}"


# ---------------------------------------------------------
# Install Docker
# ---------------------------------------------------------

echo "Installing Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed."
else
    if command -v dnf >/dev/null 2>&1; then
        dnf update -y
        dnf install -y docker
    elif command -v yum >/dev/null 2>&1; then
        yum update -y
        yum install -y docker
    else
        echo "ERROR: Unsupported package manager."
        exit 1
    fi
fi


# ---------------------------------------------------------
# Start Docker
# ---------------------------------------------------------

echo "Starting Docker service..."

systemctl enable docker
systemctl start docker


# ---------------------------------------------------------
# Verify Docker
# ---------------------------------------------------------

if ! systemctl is-active --quiet docker; then
    echo "ERROR: Docker service is not running."
    exit 1
fi

echo "Docker is running."


# ---------------------------------------------------------
# Create application directory
# ---------------------------------------------------------

mkdir -p /opt/${APP_NAME}

chmod 755 /opt/${APP_NAME}


# ---------------------------------------------------------
# Retrieve database credentials
# ---------------------------------------------------------

if [ -n "$DB_SECRET_ARN" ]; then

    echo "Retrieving database credentials from AWS Secrets Manager..."

    SECRET_JSON=$(aws secretsmanager get-secret-value \
        --secret-id "$DB_SECRET_ARN" \
        --region "$AWS_REGION" \
        --query SecretString \
        --output text)

    if [ -z "$SECRET_JSON" ] || [ "$SECRET_JSON" = "None" ]; then
        echo "ERROR: Unable to retrieve database secret."
        exit 1
    fi

    DB_USERNAME=$(echo "$SECRET_JSON" | python3 -c \
        'import sys,json; print(json.load(sys.stdin)["username"])')

    DB_PASSWORD=$(echo "$SECRET_JSON" | python3 -c \
        'import sys,json; print(json.load(sys.stdin)["password"])')

    SECRET_DB_NAME=$(echo "$SECRET_JSON" | python3 -c \
        'import sys,json; print(json.load(sys.stdin)["database"])')

    if [ -n "$SECRET_DB_NAME" ]; then
        DB_NAME="$SECRET_DB_NAME"
    fi

else

    echo "WARNING: DB_SECRET_ARN was not provided."
    echo "Database credentials will not be configured."

fi


# ---------------------------------------------------------
# Create application environment file
# ---------------------------------------------------------

cat > /opt/${APP_NAME}/application.env <<EOF
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_NAME=${DB_NAME}
DB_USERNAME=${DB_USERNAME:-}
DB_PASSWORD=${DB_PASSWORD:-}
NODE_ENV=production
PORT=${APP_PORT}
EOF

chmod 600 /opt/${APP_NAME}/application.env


# ---------------------------------------------------------
# Pull application Docker image
# ---------------------------------------------------------

if [ -z "$APP_IMAGE" ]; then
    echo "ERROR: APP_IMAGE environment variable is not set."
    exit 1
fi

echo "Pulling application image..."

docker pull "$APP_IMAGE"


# ---------------------------------------------------------
# Remove previous application container
# ---------------------------------------------------------

if docker ps -a --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then

    echo "Removing existing application container..."

    docker rm -f "$APP_NAME" || true

fi


# ---------------------------------------------------------
# Start application container
# ---------------------------------------------------------

echo "Starting application container..."

docker run -d \
    --name "$APP_NAME" \
    --restart unless-stopped \
    --env-file /opt/${APP_NAME}/application.env \
    -p ${APP_PORT}:${APP_PORT} \
    "$APP_IMAGE"


# ---------------------------------------------------------
# Verify container
# ---------------------------------------------------------

sleep 10

if docker ps --format '{{.Names}}' | grep -q "^${APP_NAME}$"; then
    echo "========================================="
    echo "Application started successfully"
    echo "========================================="
else
    echo "ERROR: Application container failed to start."
    docker logs "$APP_NAME" || true
    exit 1
fi
