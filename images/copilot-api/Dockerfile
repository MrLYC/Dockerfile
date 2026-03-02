# syntax=docker/dockerfile:1

# ==========================================
# Builder Stage
# ==========================================
FROM oven/bun:1.2.19-alpine AS builder

# Set working directory
WORKDIR /app

# Clone the repository
RUN apk add --no-cache git && \
    git clone --depth 1 https://github.com/ericc-ch/copilot-api.git . && \
    rm -rf .git

# Install dependencies and build
RUN bun install --frozen-lockfile && \
    bun run build

# ==========================================
# Runner Stage
# ==========================================
FROM oven/bun:1.2.19-alpine AS runner

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    tini \
    wget

# Create non-root user
RUN addgroup -g 1000 -S copilot && \
    adduser -u 1000 -S copilot -G copilot && \
    mkdir -p /home/copilot/.local/share/copilot-api && \
    chown -R copilot:copilot /home/copilot

# Set working directory
WORKDIR /app

# Copy built application from builder
COPY --from=builder --chown=copilot:copilot /app/dist ./dist
COPY --from=builder --chown=copilot:copilot /app/package.json ./package.json
COPY --from=builder --chown=copilot:copilot /app/bun.lock ./bun.lock
COPY --from=builder --chown=copilot:copilot /app/entrypoint.sh ./entrypoint.sh

# Install production dependencies only
RUN bun install --production --ignore-scripts --no-cache && \
    chmod +x entrypoint.sh

# Switch to non-root user
USER copilot

# Expose port
EXPOSE 4141

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --spider http://localhost:4141/ || exit 1

# Set entrypoint
ENTRYPOINT ["tini", "--", "./entrypoint.sh"]

# Default command (can be overridden with --auth)
CMD []

# Metadata
LABEL org.opencontainers.image.title="Copilot API" \
      org.opencontainers.image.description="Turn GitHub Copilot into OpenAI/Anthropic API compatible server" \
      org.opencontainers.image.url="https://github.com/ericc-ch/copilot-api" \
      org.opencontainers.image.source="https://github.com/ericc-ch/copilot-api" \
      org.opencontainers.image.vendor="ericc-ch" \
      org.opencontainers.image.licenses="MIT"
