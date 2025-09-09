# Versifier - Python dependency management tools
FROM python:3.11-alpine AS builder

# Install system dependencies required for building
RUN apk add --no-cache \
    build-base \
    git

# Set working directory
WORKDIR /app

# Install versifier from PyPI
RUN pip install --no-cache-dir versifier

# Final stage - minimal runtime image
FROM python:3.11-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    git \
    ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S versifier && \
    adduser -S versifier -u 1001 -G versifier

# Copy versifier installation from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin/versifier /usr/local/bin/

# Create working directory
WORKDIR /workspace

# Change ownership to non-root user
RUN chown -R versifier:versifier /workspace

# Switch to non-root user
USER versifier

# Default command - show help
ENTRYPOINT ["versifier"]
CMD ["--help"]