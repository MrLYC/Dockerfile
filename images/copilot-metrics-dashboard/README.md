# Microsoft Copilot Metrics Dashboard

A Docker image for running the Microsoft Copilot Metrics Dashboard, which provides analytics and insights for GitHub Copilot usage in your organization.

## Features

### 📊 **Analytics & Insights**
- **Usage Metrics**: Track Copilot usage across teams and repositories
- **Adoption Tracking**: Monitor Copilot adoption rates
- **Performance Insights**: Analyze code completion effectiveness
- **Team Analytics**: Compare usage patterns across different teams

### 🔧 **Technical Features**
- **Multi-stage Build**: Optimized Docker image with minimal footprint
- **Security First**: Non-root user execution
- **Health Checks**: Built-in monitoring endpoints
- **Scalable**: Support for PostgreSQL and Redis
- **Configurable**: Extensive environment variable configuration

### 🔒 **Security & Authentication**
- GitHub OAuth integration (optional)
- Session management
- CORS configuration
- Rate limiting protection

## Quick Start

### Basic Usage
```bash
# Build the image
docker build -t copilot-metrics-dashboard .

# Run with minimal configuration
docker run -d \
  -p 3000:3000 \
  -e GITHUB_TOKEN=your_github_token \
  -e GITHUB_ORG=your_organization \
  copilot-metrics-dashboard
```

### Using Docker Compose
```bash
# Copy environment file
cp .env.example .env

# Edit configuration
vim .env

# Start the stack
docker-compose -f docker-compose.example.yml up -d
```

## Configuration

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `GITHUB_TOKEN` | GitHub Personal Access Token | `ghp_xxxxxxxxxxxx` |
| `GITHUB_ORG` | GitHub organization name | `microsoft` |

### Optional Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `GITHUB_ENTERPRISE_NAME` | GitHub Enterprise name | - |
| `GITHUB_API_SCOPE` | API scope (organization/enterprise) | `organization` |
| `ENABLE_SEATS_FEATURE` | Enable seats feature | `true` |
| `ENABLE_SEATS_INGESTION` | Enable seats data ingestion | `true` |
| `PORT` | Application port | `3000` |
| `NODE_ENV` | Node environment | `production` |

### Authentication (Optional)

| Variable | Description |
|----------|-------------|
| `AUTH_ENABLED` | Enable GitHub OAuth |
| `AUTH_GITHUB_CLIENT_ID` | GitHub OAuth App Client ID |
| `AUTH_GITHUB_CLIENT_SECRET` | GitHub OAuth App Client Secret |

## GitHub Token Permissions

Your GitHub token needs the following permissions:

### For GitHub.com:
- `repo` (for private repositories)
- `read:org` (for organization data)
- `read:user` (for user information)

### For GitHub Enterprise:
- `repo`
- `admin:org`
- `read:user`

## Usage Examples

### Development Setup
```bash
# Clone and build
git clone https://github.com/your-org/Dockerfile.git
cd Dockerfile/images/copilot-metrics-dashboard

# Build image
docker build -t copilot-dashboard:dev .

# Run with development config
docker run -it --rm \
  -p 3000:3000 \
  -e GITHUB_TOKEN=$GITHUB_TOKEN \
  -e GITHUB_ORG=your-org \
  -e NODE_ENV=development \
  -e LOG_LEVEL=debug \
  copilot-dashboard:dev
```

### Production Deployment
```bash
# Use Docker Compose for production
cp docker-compose.example.yml docker-compose.yml
cp .env.example .env

# Configure environment variables
vim .env

# Deploy
docker-compose up -d

# Check logs
docker-compose logs -f copilot-dashboard
```

### With External Database
```bash
docker run -d \
  -p 3000:3000 \
  -e GITHUB_TOKEN=your_token \
  -e GITHUB_ORG=your_org \
  -e DATABASE_URL=postgresql://user:pass@db:5432/copilot \
  -e REDIS_URL=redis://redis:6379 \
  copilot-metrics-dashboard
```

### Enterprise GitHub Setup
```bash
docker run -d \
  -p 3000:3000 \
  -e GITHUB_TOKEN=your_enterprise_token \
  -e GITHUB_ENTERPRISE_URL=https://github.company.com \
  -e GITHUB_ORG=your_enterprise_org \
  copilot-metrics-dashboard
```

## Monitoring & Observability

### Health Checks
```bash
# Check application health
curl http://localhost:3000/health

# Prometheus metrics
curl http://localhost:3000/metrics
```

### Logging
```bash
# View application logs
docker logs copilot-metrics-dashboard

# Follow logs
docker logs -f copilot-metrics-dashboard
```

### Monitoring Stack
The included Docker Compose setup provides:
- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **Redis**: Caching layer
- **PostgreSQL**: Data persistence

## Networking

### Ports
- **3000**: Main application (HTTP)
- **5432**: PostgreSQL (if using Docker Compose)
- **6379**: Redis (if using Docker Compose)
- **9090**: Prometheus (if enabled)
- **3001**: Grafana (if enabled)

### Reverse Proxy Setup
```nginx
# nginx.conf example
upstream copilot_dashboard {
    server copilot-dashboard:3000;
}

server {
    listen 80;
    server_name copilot-metrics.company.com;
    
    location / {
        proxy_pass http://copilot_dashboard;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Security Considerations

### Production Recommendations
1. **Use HTTPS**: Always use SSL/TLS in production
2. **Secure Tokens**: Store GitHub tokens securely (use secrets management)
3. **Network Security**: Use private networks for database connections
4. **Access Control**: Enable authentication for production deployments
5. **Regular Updates**: Keep the image updated with security patches

### Environment Security
```bash
# Use Docker secrets for sensitive data
echo "your_github_token" | docker secret create github_token -

# Mount secrets in container
docker service create \
  --name copilot-dashboard \
  --secret github_token \
  --env GITHUB_TOKEN_FILE=/run/secrets/github_token \
  copilot-metrics-dashboard
```

## Troubleshooting

### Common Issues

#### Authentication Errors
```bash
# Verify token permissions
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user

# Check organization access
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/orgs/your-org
```

#### Rate Limiting
```bash
# Check rate limit status
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/rate_limit
```

#### Database Connection
```bash
# Test PostgreSQL connection
docker exec -it copilot-postgres psql -U postgres -d copilot_metrics -c "SELECT 1;"

# Test Redis connection
docker exec -it copilot-redis redis-cli ping
```

### Debug Mode
```bash
# Run with debug logging
docker run -it --rm \
  -e LOG_LEVEL=debug \
  -e NODE_ENV=development \
  copilot-metrics-dashboard
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Test your changes locally
4. Update documentation
5. Submit a pull request

## License

This Docker image is based on the Microsoft Copilot Metrics Dashboard project. Please refer to the original project's license terms.

## Support

For issues related to:
- **Docker image**: Create an issue in this repository
- **Dashboard functionality**: Refer to the [Microsoft Copilot Metrics Dashboard](https://github.com/microsoft/copilot-metrics-dashboard) repository
- **GitHub Copilot**: Contact GitHub Support
