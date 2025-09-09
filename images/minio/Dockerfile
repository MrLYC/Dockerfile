# Modern MinIO Object Storage Server
FROM alpine:3.18

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="MinIO object storage server with modern configuration"
LABEL version="2.0"

# Install dependencies
RUN apk add --no-cache \
        ca-certificates \
        curl \
        jq && \
    rm -rf /var/cache/apk/*

# Download and install MinIO
ARG MINIO_VERSION=RELEASE.2024-01-31T20-20-33Z
RUN curl -L "https://dl.min.io/server/minio/release/linux-amd64/archive/minio.${MINIO_VERSION}" -o /usr/local/bin/minio && \
    chmod +x /usr/local/bin/minio

# Download and install MinIO Client (mc)
RUN curl -L "https://dl.min.io/client/mc/release/linux-amd64/mc" -o /usr/local/bin/mc && \
    chmod +x /usr/local/bin/mc

# Create minio user and group
RUN addgroup -g 1001 -S minio && \
    adduser -S minio -u 1001 -G minio

# Environment variables with secure defaults
ENV MINIO_ROOT_USER=""
ENV MINIO_ROOT_PASSWORD=""
ENV MINIO_ACCESS_KEY=""
ENV MINIO_SECRET_KEY=""
ENV MINIO_REGION="us-east-1"
ENV MINIO_BROWSER="on"
ENV MINIO_DOMAIN=""
ENV MINIO_SERVER_URL=""
ENV MINIO_STORAGE_CLASS_STANDARD=""

# Legacy environment variables (deprecated but maintained for compatibility)
ENV BUCKET_ROOT="/data"
ENV CONFIG_DIR="/data/.minio"
ENV ACCESS_KEY=""
ENV SECRET_KEY=""
ENV REGION="us-east-1"

# Copy entrypoint script
COPY entry.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create data directory and set permissions
RUN mkdir -p /data && \
    chown minio:minio /data

# Expose MinIO API and Console ports
EXPOSE 9000 9001

# Volume for data
VOLUME ["/data"]

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000/minio/health/live || exit 1

# Switch to minio user
USER minio

# Working directory
WORKDIR /data

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["server", "/data", "--console-address", ":9001"]
