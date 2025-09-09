# Simple build for dev-kit MCP server using official installation method
FROM golang:1.23.2-alpine AS builder

# Install ca-certificates for HTTPS requests
RUN apk add --no-cache ca-certificates

# Install dev-kit using the official recommended method
RUN go install github.com/nguyenvanduocit/dev-kit@latest

# Final stage - minimal runtime image
FROM alpine:latest

# Install ca-certificates for HTTPS requests
RUN apk --no-cache add ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S devkit && \
    adduser -S devkit -u 1001 -G devkit

WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /go/bin/dev-kit .

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