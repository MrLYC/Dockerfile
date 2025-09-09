# DevTeam Development Environment

A comprehensive Docker image for development teams with pre-installed tools and environments for modern software development.

## Features

### 🛠️ Development Tools
- **Node.js** (LTS) with npm, yarn, pnpm
- **Python 3** with pip and virtual environment
- **Go** (latest stable) with common tools
- **Git** with sensible defaults
- **Docker CLI** and Docker Compose
- **kubectl** for Kubernetes management
- **Terraform** for infrastructure as code

### 🚀 Frameworks & Libraries
- **Frontend**: Angular CLI, Vue CLI, Create React App
- **Backend**: Flask, FastAPI, Django, Gin (Go)
- **AI/ML**: OpenAI, LangChain, Transformers, Pandas, NumPy
- **DevOps**: Ansible, AWS CLI, Kubernetes client

### 💻 Development Environment
- **VS Code Server** (code-server) - VS Code in browser
- **Jupyter Lab** - Interactive notebooks
- **Multiple language support** with proper tooling
- **Non-root user** (`devteam`) for security

### 🔧 System Tools
- Build tools (make, gcc, etc.)
- Network utilities (curl, wget, ping, telnet)
- Database clients (MySQL, PostgreSQL, Redis)
- Debugging tools (strace, tcpdump)
- Process management (htop, supervisor)

## Quick Start

### Interactive Development Shell
```bash
# Start an interactive development environment
docker run -it -v $(pwd):/workspace devteam

# Mount your project directory and start developing
docker run -it -v /path/to/your/project:/workspace devteam bash
```

### VS Code in Browser
```bash
# Start VS Code Server accessible at http://localhost:8080
docker run -it -p 8080:8080 -v $(pwd):/workspace devteam code-server
```

### Jupyter Lab
```bash
# Start Jupyter Lab accessible at http://localhost:8888
docker run -it -p 8888:8888 -v $(pwd):/workspace devteam jupyter
```

### Custom Command
```bash
# Run any command in the development environment
docker run -it -v $(pwd):/workspace devteam "npm install && npm start"
```

## Usage Examples

### Frontend Development
```bash
# React development
docker run -it -p 3000:3000 -v $(pwd):/workspace devteam bash -c "
  npx create-react-app my-app
  cd my-app
  npm start
"

# Angular development
docker run -it -p 4200:4200 -v $(pwd):/workspace devteam bash -c "
  ng new my-app
  cd my-app
  ng serve --host 0.0.0.0
"

# Vue development
docker run -it -p 8080:8080 -v $(pwd):/workspace devteam bash -c "
  vue create my-app
  cd my-app
  npm run serve
"
```

### Backend Development
```bash
# Python Flask development
docker run -it -p 5000:5000 -v $(pwd):/workspace devteam bash -c "
  python -m venv venv
  source venv/bin/activate
  pip install flask
  python app.py
"

# Go development
docker run -it -p 8000:8000 -v $(pwd):/workspace devteam bash -c "
  go mod init myapp
  go run main.go
"

# Node.js development
docker run -it -p 3000:3000 -v $(pwd):/workspace devteam bash -c "
  npm init -y
  npm install express
  node server.js
"
```

### Data Science & AI Development
```bash
# Jupyter Lab for data science
docker run -it -p 8888:8888 -v $(pwd):/workspace devteam jupyter

# Python AI/ML development
docker run -it -v $(pwd):/workspace devteam bash -c "
  source /home/devteam/venv/bin/activate
  pip install torch transformers datasets
  python train_model.py
"
```

### DevOps & Infrastructure
```bash
# Terraform operations
docker run -it -v $(pwd):/workspace -v ~/.aws:/home/devteam/.aws devteam bash -c "
  terraform init
  terraform plan
  terraform apply
"

# Kubernetes operations
docker run -it -v ~/.kube:/home/devteam/.kube devteam bash -c "
  kubectl get pods
  kubectl apply -f deployment.yaml
"

# Ansible playbooks
docker run -it -v $(pwd):/workspace devteam bash -c "
  ansible-playbook -i inventory playbook.yml
"
```

## Docker Compose Integration

Create a `docker-compose.yml` for persistent development:

```yaml
version: '3.8'
services:
  devteam:
    image: devteam:latest
    ports:
      - "8080:8080"    # VS Code Server
      - "8888:8888"    # Jupyter Lab
      - "3000:3000"    # Frontend dev server
      - "5000:5000"    # Backend dev server
    volumes:
      - .:/workspace
      - devteam-home:/home/devteam
      - /var/run/docker.sock:/var/run/docker.sock  # Docker-in-Docker
    environment:
      - GIT_USER_NAME=Your Name
      - GIT_USER_EMAIL=your.email@example.com
    command: code-server

volumes:
  devteam-home:
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `GIT_USER_NAME` | Git user name for commits | `DevTeam` |
| `GIT_USER_EMAIL` | Git user email for commits | `devteam@example.com` |
| `WORKSPACE_DIR` | Working directory inside container | `/workspace` |

## Customization

### Extending the Image
```dockerfile
FROM devteam:latest

# Install additional tools
USER root
RUN apt-get update && apt-get install -y your-tool
USER devteam

# Add your custom configurations
COPY --chown=devteam:devteam .vimrc /home/devteam/
COPY --chown=devteam:devteam .gitconfig /home/devteam/
```

### Custom VS Code Extensions
```bash
# Install extensions in running container
docker exec -it container_name bash -c "
  code-server --install-extension ms-python.python
  code-server --install-extension golang.go
"
```

### Persistent Configuration
Mount configuration directories to persist settings:
```bash
docker run -it \
  -v $(pwd):/workspace \
  -v ~/.gitconfig:/home/devteam/.gitconfig \
  -v ~/.ssh:/home/devteam/.ssh:ro \
  -v vscode-config:/home/devteam/.local/share/code-server \
  devteam
```

## Security Considerations

### Non-Root User
- Runs as `devteam` user (UID: 1001, GID: 1001)
- Has sudo access for development convenience
- Passwordless sudo enabled for development workflow

### Volume Mounting
```bash
# Safe: Mount specific directories
-v $(pwd):/workspace

# Careful: Docker socket access (for Docker-in-Docker)
-v /var/run/docker.sock:/var/run/docker.sock

# Secure: Read-only mounts for config
-v ~/.ssh:/home/devteam/.ssh:ro
```

## Troubleshooting

### Permission Issues
```bash
# Fix ownership of workspace files
docker run --rm -v $(pwd):/workspace devteam sudo chown -R devteam:devteam /workspace
```

### Port Conflicts
```bash
# Use different ports if default ones are occupied
docker run -it -p 8081:8080 -p 8889:8888 devteam
```

### Memory Issues
```bash
# Increase Docker memory limit
docker run -it --memory=4g devteam
```

### Git Configuration
```bash
# Set git credentials in running container
docker exec -it container_name bash -c "
  git config --global user.name 'Your Name'
  git config --global user.email 'your.email@example.com'
"
```

## Building Locally

```bash
# Build the image
cd images/devteam
docker build -t devteam:latest .

# Build with custom tag
docker build -t devteam:v1.0.0 .

# Build with build args
docker build --build-arg GO_VERSION=1.22.0 -t devteam:custom .
```

## Included Software Versions

- **Ubuntu**: 22.04 LTS
- **Node.js**: LTS (20.x)
- **Python**: 3.10+
- **Go**: 1.23.2
- **Docker CLI**: Latest stable
- **kubectl**: Latest stable
- **Terraform**: 1.6.0
- **VS Code Server**: Latest

## Contributing

1. Fork the repository
2. Create your feature branch
3. Test your changes with the local build
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Create an issue in the GitHub repository
- Check the troubleshooting section above
- Review Docker logs: `docker logs container_name`
