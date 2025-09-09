# Multi-stage build for IMAP MCP server
FROM python:3.11-alpine AS builder

# Install system dependencies required for building
RUN apk add --no-cache \
    build-base \
    libffi-dev \
    openssl-dev \
    curl

# Install uv package manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /app

# Clone the imap-mcp repository
RUN git clone https://github.com/non-dirty/imap-mcp.git .

# Create virtual environment and install dependencies
RUN uv venv && \
    uv pip install -e ".[dev]"

# Final stage - minimal runtime image
FROM python:3.11-alpine

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    libffi \
    openssl

# Install uv for runtime
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Create non-root user
RUN addgroup -g 1001 -S imapuser && \
    adduser -S imapuser -u 1001 -G imapuser

WORKDIR /app

# Copy the application and virtual environment from builder
COPY --from=builder /app .
COPY --from=builder /app/.venv ./.venv

# Create directories for configuration
RUN mkdir -p /app/config && \
    chown -R imapuser:imapuser /app

# Switch to non-root user
USER imapuser

# Activate virtual environment
ENV VIRTUAL_ENV="/app/.venv"
ENV PATH="/app/.venv/bin:$PATH"

# Expose default port (if needed for debugging)
EXPOSE 8080

# Default command - run the MCP server
ENTRYPOINT ["uv", "run", "imap_mcp.server"]

# Default arguments - can be overridden
CMD ["--config", "/app/config/config.yaml"]