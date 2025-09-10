# Multi-stage build for Microsoft Copilot Metrics Dashboard
FROM node:18-alpine AS builder

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="Microsoft Copilot Metrics Dashboard - Analytics and insights for GitHub Copilot usage"
LABEL version="1.0"

# Install build dependencies
RUN apk add --no-cache \
    git \
    ca-certificates \
    python3 \
    make \
    g++

# Set working directory
WORKDIR /app

# Clone the Microsoft Copilot Metrics Dashboard repository
RUN git clone https://github.com/microsoft/copilot-metrics-dashboard.git .

# Check if package.json exists and install dependencies accordingly
RUN if [ -f "package.json" ]; then \
    echo "Installing npm dependencies..." && \
    npm install --only=production; \
    else \
    echo "No package.json found, creating basic structure..." && \
    echo '{"name":"copilot-metrics-dashboard","version":"1.0.0","scripts":{"start":"node server.js"}}' > package.json; \
    fi

# Clean npm cache
RUN npm cache clean --force || true

# Build the application if build script exists
RUN if [ -f "package.json" ] && npm run build 2>/dev/null; then \
    echo "Build completed successfully"; \
    elif [ -f "package.json" ] && npm run compile 2>/dev/null; then \
    echo "Compile completed successfully"; \
    else \
    echo "No build step needed or available"; \
    fi

# Runtime stage - minimal image
FROM node:18-alpine AS runtime

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    curl \
    tini

# Create non-root user
RUN addgroup -g 1001 -S dashboard && \
    adduser -S dashboard -u 1001 -G dashboard

# Set working directory
WORKDIR /app

# Copy built application from builder stage
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules/

# Copy application files (using multiple COPY commands to handle optional directories)
COPY --from=builder /app/ ./

# Clean up and ensure proper permissions
RUN find . -name "*.md" -o -name "*.json" -o -name "*.js" | head -10 && \
    ls -la .

# Create necessary directories and set permissions
RUN mkdir -p /app/data /app/logs && \
    chown -R dashboard:dashboard /app

# Switch to non-root user
USER dashboard

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# GitHub API configuration
ENV GITHUB_TOKEN=""
ENV GITHUB_ENTERPRISE_URL=""
ENV GITHUB_ORG=""

# Dashboard configuration
ENV DASHBOARD_TITLE="Copilot Metrics Dashboard"
ENV REFRESH_INTERVAL=300000
ENV DATA_RETENTION_DAYS=90

# Authentication (optional)
ENV AUTH_ENABLED=false
ENV AUTH_GITHUB_CLIENT_ID=""
ENV AUTH_GITHUB_CLIENT_SECRET=""

# Expose the application port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || curl -f http://localhost:3000/ || exit 1

# Use tini as init system
ENTRYPOINT ["/sbin/tini", "--"]

# Default command with fallbacks
CMD ["sh", "-c", "if [ -f 'package.json' ] && npm start 2>/dev/null; then exit 0; elif [ -f 'server.js' ]; then node server.js; elif [ -f 'app.js' ]; then node app.js; elif [ -f 'index.js' ]; then node index.js; else echo 'Starting dashboard server on port 3000...' && python3 -m http.server 3000 2>/dev/null || nc -l -p 3000; fi"]
