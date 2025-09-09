# Multi-stage build for Development Team Environment
FROM ubuntu:22.04 AS base

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install system dependencies and basic tools
RUN apt-get update && apt-get install -y \
    # Basic system tools
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    unzip \
    zip \
    jq \
    make \
    build-essential \
    software-properties-common \
    ca-certificates \
    gnupg \
    lsb-release \
    # Network tools
    net-tools \
    iputils-ping \
    telnet \
    # Process management
    supervisor \
    # SSL/TLS support
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (LTS version)
FROM base AS node-installer
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    # Install popular global packages
    npm install -g \
    yarn \
    pnpm \
    typescript \
    ts-node \
    @angular/cli \
    @vue/cli \
    create-react-app \
    eslint \
    prettier \
    pm2

# Install Python and packages
FROM node-installer AS python-installer
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    && ln -s /usr/bin/python3 /usr/bin/python \
    && python -m pip install --upgrade pip \
    && pip install \
    # Core development packages
    requests \
    flask \
    fastapi \
    django \
    jupyter \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    # DevOps and automation
    ansible \
    boto3 \
    kubernetes \
    docker \
    # Code quality
    black \
    flake8 \
    pylint \
    pytest \
    # AI/ML libraries
    openai \
    langchain \
    transformers \
    && rm -rf /var/lib/apt/lists/*

# Install Go
FROM python-installer AS go-installer
ENV GO_VERSION=1.23.2
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Install popular Go tools
RUN go install github.com/cosmtrek/air@latest && \
    go install github.com/gin-gonic/gin@latest && \
    go install golang.org/x/tools/gopls@latest && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Install Docker CLI and Docker Compose
FROM go-installer AS docker-installer
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Install additional development tools
FROM docker-installer AS tools-installer
RUN apt-get update && apt-get install -y \
    # Database clients
    mysql-client \
    postgresql-client \
    redis-tools \
    # Cloud CLI tools
    awscli \
    # Monitoring and debugging
    strace \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Install Terraform
ENV TERRAFORM_VERSION=1.6.0
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install code-server (VS Code in browser)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Final stage - create the runtime environment
FROM tools-installer AS final

# Create development user and group
RUN groupadd -g 1001 devteam && \
    useradd -u 1001 -g devteam -m -s /bin/bash devteam && \
    # Add user to sudo group for development needs
    usermod -aG sudo devteam && \
    # Allow sudo without password for convenience in development
    echo "devteam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create common development directories
RUN mkdir -p /workspace /home/devteam/.config /home/devteam/.ssh && \
    chown -R devteam:devteam /workspace /home/devteam

# Set up Go environment for the user
USER devteam
ENV GOPATH=/home/devteam/go \
    GOROOT=/usr/local/go \
    PATH="/usr/local/go/bin:/home/devteam/go/bin:${PATH}"

RUN mkdir -p $GOPATH/bin $GOPATH/src $GOPATH/pkg

# Set up Python virtual environment
RUN python -m venv /home/devteam/venv
ENV PATH="/home/devteam/venv/bin:${PATH}"

# Configure git (user can override these)
RUN git config --global user.name "DevTeam" && \
    git config --global user.email "devteam@example.com" && \
    git config --global init.defaultBranch main

# Set working directory
WORKDIR /workspace

# Create entrypoint script
USER root
RUN cat > /entrypoint.sh << 'EOF'
#!/bin/bash

# Function to display available services
show_services() {
    echo "Available services:"
    echo "  code-server  - VS Code in browser (port 8080)"
    echo "  jupyter      - Jupyter Lab (port 8888)"
    echo "  bash         - Interactive bash shell"
    echo ""
    echo "Usage examples:"
    echo "  docker run -it -p 8080:8080 devteam code-server"
    echo "  docker run -it -p 8888:8888 devteam jupyter"
    echo "  docker run -it -v \$(pwd):/workspace devteam bash"
}

# Set permissions for workspace
chown -R devteam:devteam /workspace

case "$1" in
    "code-server")
        echo "Starting VS Code Server on port 8080..."
        exec su - devteam -c "cd /workspace && code-server --bind-addr 0.0.0.0:8080 --auth none --disable-telemetry"
        ;;
    "jupyter")
        echo "Starting Jupyter Lab on port 8888..."
        exec su - devteam -c "cd /workspace && source /home/devteam/venv/bin/activate && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root --NotebookApp.token=''"
        ;;
    "bash"|"sh")
        exec su - devteam -c "cd /workspace && bash"
        ;;
    "help"|"--help"|"-h")
        show_services
        ;;
    "")
        echo "DevTeam Development Environment"
        echo "==============================="
        echo ""
        show_services
        exec su - devteam -c "cd /workspace && bash"
        ;;
    *)
        # Pass through any other commands
        exec su - devteam -c "cd /workspace && $*"
        ;;
esac
EOF

RUN chmod +x /entrypoint.sh

# Switch back to devteam user
USER devteam

# Expose common development ports
EXPOSE 3000 3001 4200 5000 8000 8080 8888 9000

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command shows help
CMD ["help"]
