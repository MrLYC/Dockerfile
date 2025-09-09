# Multi-stage build for dev-kit MCP server
FROM golang:1.23.2-alpine AS builder

# Install git and other build dependencies
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# Clone the dev-kit repository
RUN git clone https://github.com/nguyenvanduocit/dev-kit.git .

# Download dependencies
RUN go mod download

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o dev-kit .

# Final stage - minimal runtime image
FROM alpine:latest

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S devkit && \
    adduser -S devkit -u 1001 -G devkit

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /app/dev-kit .

# Create directory for environment file
RUN mkdir -p /app/config

# Change ownership to non-root user
RUN chown -R devkit:devkit /app

# Switch to non-root user
USER devkit

# Expose default SSE port
EXPOSE 8080

# Default command - use stdio protocol
ENTRYPOINT ["./dev-kit"]

# Default arguments - can be overridden
CMD ["-protocol", "stdio"]