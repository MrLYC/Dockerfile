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
RUN git clone -b v1.2.0 https://github.com/microsoft/copilot-metrics-dashboard.git .
#RUN git clone -b fix-teams-filters https://github.com/sandeep0402/copilot-metrics-dashboard.git .

# Navigate to the dashboard directory where package.json is located
WORKDIR /app/src/dashboard

# Install dependencies
RUN npm install

# Build the Next.js application
RUN npm run build

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

# Copy package.json and dependencies from builder stage
COPY --from=builder /app/src/dashboard/package*.json ./
COPY --from=builder /app/src/dashboard/node_modules ./node_modules/

# Copy built application from builder stage
COPY --from=builder /app/src/dashboard/.next ./.next/
COPY --from=builder /app/src/dashboard/public ./public/
COPY --from=builder /app/src/dashboard/next.config.* ./

# Create necessary directories and set permissions
RUN mkdir -p /app/data /app/logs && \
    chown -R dashboard:dashboard /app

# Switch to non-root user
USER dashboard

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# GitHub API configuration (required)
ENV GITHUB_TOKEN=""
ENV GITHUB_ENTERPRISE_NAME=""
ENV GITHUB_ORG=""
ENV GITHUB_API_SCOPE="organization"

# Dashboard configuration
ENV ENABLE_SEATS_FEATURE=true
ENV ENABLE_SEATS_INGESTION=true

# Expose the application port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || curl -f http://localhost:3000/ || exit 1

# Use tini as init system
ENTRYPOINT ["/sbin/tini", "--"]

# Start the Next.js application
CMD ["npm", "start"]
