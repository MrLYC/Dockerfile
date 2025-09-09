# Build dev-kit MCP server from source with fixes
FROM golang:1.23.2-alpine AS builder

# Install required tools
RUN apk add --no-cache git ca-certificates

# Set working directory
WORKDIR /app

# Clone the repository and checkout a specific working version
# Using commit before the API breaking changes
RUN git clone https://github.com/nguyenvanduocit/dev-kit.git . && \
    git checkout v1.2.0

# Set Go environment
ENV GO111MODULE=on
ENV GOPROXY=https://proxy.golang.org,direct

# Download dependencies and build
RUN go mod download && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o dev-kit .

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