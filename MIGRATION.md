# Migrated Docker Images

This document provides an overview of all Docker images that have been migrated from individual branches to the unified `images/` directory structure.

## Migration Summary

**Total Images Migrated:** 26  
**Migration Date:** 2025-09-09  
**Migration Script:** `migrate-branches.sh`

## Available Images

| Image Name | Description | Base Image | Key Features |
|------------|-------------|------------|--------------|
| `alpine-sshd` | SSH server on Alpine Linux | Alpine 3.18 | Secure SSH, non-root user, key-based auth |
| `beanstalkd` | Work queue server | Alpine | Job queue, background processing |
| `centos` | CentOS-based container | CentOS | Enterprise Linux environment |
| `chrome-vnc` | Chrome browser with VNC | Ubuntu | Remote browser access |
| `devteam` | Full development environment | Ubuntu 22.04 | Multi-language dev tools, VS Code, Jupyter |
| `docker-utils` | Docker utilities container | Alpine | Docker management tools |
| `hello-world` | Simple test container | Alpine | Basic example, testing |
| `hexo` | Static site generator | Node.js | Blog generation, static sites |
| `httplive` | HTTP live streaming | Alpine | Video streaming server |
| `ipython` | Interactive Python shell | Python | Data science, interactive computing |
| `jupyter` | Jupyter data science environment | Jupyter/datascience-notebook | Notebooks, data analysis, ML |
| `kcptun` | KCP tunnel server | Alpine | Network acceleration |
| `kcptun-client` | KCP tunnel client | Alpine | Network acceleration client |
| `lamptun` | LAMP stack tunnel | Apache/PHP | Web development stack |
| `minicron` | Lightweight cron daemon | Alpine | Job scheduling |
| `minio` | Object storage server | Alpine 3.18 | S3-compatible storage |
| `nextcloud` | Cloud storage platform | Apache/PHP | File sharing, collaboration |
| `opengrok` | Source code search engine | Tomcat | Code indexing and search |
| `pyspider` | Python web crawler | Python | Web scraping framework |
| `snmpd` | SNMP daemon | Alpine | Network monitoring |
| `ssh-client` | SSH client utilities | Alpine | Remote access tools |
| `sslocal` | Shadowsocks local proxy | Alpine | Proxy server |
| `tox` | Python testing tool | Python | Multi-environment testing |
| `ubuntu` | Ubuntu base with tools | Ubuntu | General purpose Linux |
| `webcron` | Web-based cron interface | Alpine | Cron job management |
| `webdav` | WebDAV server | Apache | File sharing protocol |
| `yapf` | Python code formatter | Python | Code formatting tool |
| `zabbix` | Monitoring solution | Alpine | Infrastructure monitoring |

## Modernization Highlights

### Security Improvements
- **Non-root users**: All containers now run with non-root users where possible
- **Updated base images**: Using latest stable versions with security patches
- **Secure defaults**: Disabled unnecessary services and permissions

### Modern Docker Practices
- **Multi-stage builds**: Where applicable for smaller image sizes
- **Health checks**: Added health checks for critical services
- **Proper labeling**: Consistent metadata labels
- **Layer optimization**: Reduced number of layers and optimized caching

### Enhanced Documentation
- **Comprehensive READMEs**: Each image has detailed usage instructions
- **Environment variables**: Clearly documented configuration options
- **Examples**: Practical usage examples with Docker Compose

## Usage Examples

### Basic Image Building
```bash
# Build specific image
./build-images.sh alpine-sshd

# Build with custom tag
./build-images.sh -t v2.0.0 jupyter

# Build all images
./build-images.sh --all

# Dry run to see commands
./build-images.sh --dry-run minio
```

### Running Migrated Images

#### SSH Server
```bash
docker run -d -p 2222:22 \
  -e SSH_USER=developer \
  -e AUTHORIZED_KEYS="$(cat ~/.ssh/id_rsa.pub)" \
  alpine-sshd
```

#### Jupyter Data Science
```bash
docker run -d -p 8888:8888 \
  -e JUPYTER_TOKEN=my-secret-token \
  -v $(pwd)/notebooks:/home/jovyan/work \
  jupyter
```

#### MinIO Object Storage
```bash
docker run -d -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=admin \
  -e MINIO_ROOT_PASSWORD=password123 \
  -v minio-data:/data \
  minio
```

#### Development Environment
```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your@email.com" \
  devteam code-server
```

## Migration Benefits

### Organizational
- **Unified structure**: All images in one repository with consistent structure
- **Centralized management**: Single build system for all images
- **Version control**: Proper Git history for all images

### Operational
- **Automated building**: GitHub Actions integration for CI/CD
- **Consistent tagging**: Uniform versioning across all images
- **Quality assurance**: Standardized testing and validation

### Development
- **Modern tooling**: Updated to current best practices
- **Better documentation**: Comprehensive usage guides
- **Enhanced security**: Security-first approach with non-root users

## Next Steps

1. **Testing**: Validate all migrated images build and run correctly
2. **Documentation**: Enhance individual image READMEs with specific use cases
3. **CI/CD**: Update GitHub Actions to build all migrated images
4. **Security scanning**: Implement vulnerability scanning for all images
5. **Performance optimization**: Fine-tune image sizes and startup times

## Contributing

When modifying migrated images:

1. Follow the established directory structure in `images/`
2. Update the corresponding README with any changes
3. Test builds locally before committing
4. Use semantic versioning for tags
5. Consider security implications of any changes

## Support

For issues with migrated images:
- Check the individual image README for specific troubleshooting
- Review Docker logs: `docker logs <container_name>`
- Verify environment variables and volume mounts
- Ensure proper network connectivity for networked services
