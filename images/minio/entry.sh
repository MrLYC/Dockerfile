#!/bin/bash

set -e

# Function to generate random password
generate_password() {
    tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 32
}

# Function to show help
show_help() {
    echo "MinIO Object Storage Server"
    echo "=========================="
    echo ""
    echo "Environment Variables:"
    echo "  MINIO_ROOT_USER     - Root access key (required)"
    echo "  MINIO_ROOT_PASSWORD - Root secret key (required, min 8 chars)"
    echo "  MINIO_REGION        - Server region (default: us-east-1)"
    echo "  MINIO_BROWSER       - Enable web browser (default: on)"
    echo "  MINIO_DOMAIN        - Domain name for virtual-hosted-style requests"
    echo ""
    echo "Legacy Variables (deprecated but supported):"
    echo "  ACCESS_KEY          - Use MINIO_ROOT_USER instead"
    echo "  SECRET_KEY          - Use MINIO_ROOT_PASSWORD instead"
    echo ""
    echo "Usage:"
    echo "  docker run -p 9000:9000 -p 9001:9001 \\"
    echo "    -e MINIO_ROOT_USER=admin \\"
    echo "    -e MINIO_ROOT_PASSWORD=password123 \\"
    echo "    minio"
}

# Handle legacy environment variables
if [[ -n "${ACCESS_KEY}" && -z "${MINIO_ROOT_USER}" ]]; then
    export MINIO_ROOT_USER="${ACCESS_KEY}"
    echo "⚠️  Using legacy ACCESS_KEY. Please use MINIO_ROOT_USER instead."
fi

if [[ -n "${SECRET_KEY}" && -z "${MINIO_ROOT_PASSWORD}" ]]; then
    export MINIO_ROOT_PASSWORD="${SECRET_KEY}"
    echo "⚠️  Using legacy SECRET_KEY. Please use MINIO_ROOT_PASSWORD instead."
fi

# Validate credentials
if [[ -z "${MINIO_ROOT_USER}" ]]; then
    echo "❌ Error: MINIO_ROOT_USER is required"
    show_help
    exit 1
fi

if [[ -z "${MINIO_ROOT_PASSWORD}" ]]; then
    echo "❌ Error: MINIO_ROOT_PASSWORD is required"
    show_help
    exit 1
fi

if [[ ${#MINIO_ROOT_PASSWORD} -lt 8 ]]; then
    echo "❌ Error: MINIO_ROOT_PASSWORD must be at least 8 characters long"
    exit 1
fi

# Set default region
export MINIO_REGION=${MINIO_REGION:-"us-east-1"}

# Ensure data directory exists
mkdir -p /data

echo "🚀 Starting MinIO Object Storage Server"
echo "👤 Root User: ${MINIO_ROOT_USER}"
echo "🌍 Region: ${MINIO_REGION}"
echo "🌐 Console: http://localhost:9001"
echo "📡 API: http://localhost:9000"

# Handle command line arguments
if [[ $# -eq 0 ]]; then
    # Default server command
    exec minio server /data --console-address ":9001"
else
    # Custom command
    case "$1" in
        "server")
            exec minio "$@"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            exec "$@"
            ;;
    esac
fi
