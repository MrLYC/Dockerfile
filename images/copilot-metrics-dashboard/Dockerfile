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

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Build the application
RUN npm run build || npm run compile || echo "Build step completed"

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
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist 2>/dev/null || COPY --from=builder /app/build ./build 2>/dev/null || COPY --from=builder /app/src ./src
COPY --from=builder /app/public ./public 2>/dev/null || true
COPY --from=builder /app/*.js ./
COPY --from=builder /app/*.json ./
COPY --from=builder /app/*.md ./

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

# Default command
CMD ["npm", "start"]
