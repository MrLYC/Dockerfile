# Docker Images Repository - Copilot Instructions

## Project Overview

This repository contains Docker image definitions for various development tools and services.

## Repository Structure

```
/
├── .github/workflows/           # GitHub Actions CI/CD workflows
│   └── docker-build.yaml      # Multi-platform Docker build pipeline
├── images/                     # Docker image definitions
├── build-images.sh            # Build script for local testing
├── create-image.sh            # Template script for new images
├── test-images.sh             # Testing script for images
└── README.md                  # Project documentation
```

## Docker Image Standards

### Directory Structure
Each image in `images/` should follow this structure:
```
images/<image-name>/
├── Dockerfile                 # Multi-stage build preferred
├── README.md                  # Usage documentation
├── .env.example              # Configuration template (if needed)
└── config.yaml.example       # Config template (if needed)
```


#### Multi-stage Builds
- Use multi-stage builds to minimize final image size
- First stage: `builder` - install dependencies and build
- Final stage: minimal runtime image with only necessary components

#### Base Images
- **Go projects**: `golang:1.23.2-alpine AS builder` → `alpine:latest`
- **Python projects**: `python:3.11-alpine AS builder` → `python:3.11-alpine`
- **Node.js projects**: `node:18-alpine AS builder` → `node:18-alpine`

#### Security Best Practices
- Always create and use non-root users
- Use specific user/group IDs (e.g., 1001:1001)
- Install only necessary runtime dependencies
- Use `--no-cache` for apk installations

#### Example Dockerfile Template
```dockerfile
# Multi-stage build for <PROJECT_NAME>
FROM <base-image> AS builder

# Install build dependencies
RUN apk add --no-cache \
    build-base \
    git \
    ca-certificates

WORKDIR /app

# Build steps here
# ...

# Final stage - minimal runtime image
FROM <runtime-image>

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates

# Create non-root user
RUN addgroup -g 1001 -S <username> && \
    adduser -S <username> -u 1001 -G <username>

WORKDIR /app

# Copy artifacts from builder
COPY --from=builder /app/<binary> .

# Set ownership
RUN chown -R <username>:<username> /app

# Switch to non-root user
USER <username>

# Expose ports if needed
EXPOSE <port>

# Set entrypoint and default command
ENTRYPOINT ["./<binary>"]
CMD ["--help"]
```

## MCP Server Specific Guidelines

### Configuration Management
- Provide `.env.example` with all required environment variables
- Support both environment variables and config files
- Document OAuth2 setup for services like Gmail, GitHub, etc.

### Common Environment Variables
```bash
# Service-specific credentials
GITHUB_TOKEN=
GITLAB_TOKEN=
ATLASSIAN_HOST=
ATLASSIAN_EMAIL=
ATLASSIAN_TOKEN=

# Optional configurations
PROXY_URL=
ENABLE_TOOLS=
PORT=8080
```

### Protocol Support
MCP servers should support both protocols:
- **STDIO**: Default for Claude Desktop integration
- **SSE**: HTTP-based for web integration

## GitHub Actions Integration

### Build Strategy
- Multi-platform builds: `linux/amd64,linux/arm64`
- Automatic image detection based on changed files in `images/`
- Three tagging strategy:
  - Git SHA (8 chars): `a1b2c3d4`
  - Branch name: `main`, `images`
  - Latest: `latest`

### Docker Hub Integration
Images are automatically built and pushed to Docker Hub with the naming convention:
`<docker-username>/<image-name>:<tag>`

## Code Generation Guidelines

### When Creating New Images
1. Create directory in `images/<new-image-name>/`
2. Generate Dockerfile following the template above
3. Create comprehensive README.md with:
   - Feature overview
   - Build instructions
   - Usage examples
   - Configuration options
   - Security considerations
   - Troubleshooting guide

### When Modifying Existing Images
1. Preserve existing security configurations
2. Maintain backwards compatibility
3. Update documentation accordingly
4. Test builds locally before committing

### Error Handling Patterns
- Always check for required tools in Dockerfile
- Provide clear error messages in scripts
- Handle missing dependencies gracefully
- Include fallback options where possible

### Version Management
- Use specific versions for base images when stability is critical
- Pin dependency versions for reproducible builds
- Use latest stable versions for development tools
- Document version choices in comments

## Development Workflow

### Local Testing
```bash
# Build specific image
docker build -t <image-name>-test ./images/<image-name>/

# Test image functionality
docker run --rm <image-name>-test

# Test with mounted volumes
docker run --rm -v $(pwd):/workspace <image-name>-test
```

### Integration with Claude Desktop
Each MCP server should provide Claude Desktop configuration example:
```json
{
  "mcpServers": {
    "<server-name>": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-v", "/path/to/config:/app/config:ro",
        "<docker-username>/<image-name>:latest"
      ]
    }
  }
}
```

## Common Patterns

### OAuth2 Setup (for Gmail, GitHub, etc.)
1. Document required OAuth2 scope
2. Provide step-by-step setup instructions
3. Include token refresh mechanisms
4. Handle authentication errors gracefully

### Configuration Templates
- Always provide example configurations
- Document all available options
- Include security recommendations
- Provide validation where possible

### Logging and Debugging
- Support configurable log levels
- Provide debug modes for development
- Include health check endpoints where applicable
- Document troubleshooting steps

## Best Practices for AI Assistance

When working with this repository:
1. Always follow the established patterns and conventions
2. Prioritize security and minimal attack surface
3. Ensure comprehensive documentation
4. Test multi-platform compatibility
5. Maintain consistent naming and structure
6. Consider backwards compatibility
7. Document any breaking changes clearly
