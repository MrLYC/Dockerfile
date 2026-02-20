FROM debian:12-slim

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="code-server with dev extensions and Cloudflare Tunnel"

ARG CODE_SERVER_VERSION=4.108.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    curl \
    ca-certificates \
    git \
    sudo \
    wget \
    gnupg \
    netcat-openbsd \
    python3 \
    python3-pip \
    golang-go \
    && curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg -o /usr/share/keyrings/cloudflare-main.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared bookworm main" \
    > /etc/apt/sources.list.d/cloudflared.list \
    && apt-get update \
    && apt-get install -y cloudflared \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION}

RUN groupadd -g 1001 coder \
    && useradd -m -u 1001 -g 1001 -s /bin/bash coder \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir -p /run/sshd \
    && sed -i 's/#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config \
    && ssh-keygen -A

RUN code-server \
    --install-extension golang.go \
    --install-extension ms-python.python \
    --install-extension dbaeumer.vscode-eslint \
    --install-extension esbenp.prettier-vscode \
    --install-extension yzhang.markdown-all-in-one \
    --install-extension GitHub.copilot \
    --install-extension GitHub.copilot-chat \
    --install-extension opencode.opencode

# TUNNEL_TOKEN       - Cloudflare Tunnel token (required)
# SSH_PASSWORD       - SSH password for coder user (optional, at least one of SSH_PASSWORD/SSH_AUTHORIZED_KEYS required)
# SSH_AUTHORIZED_KEYS - SSH public keys for coder user (optional)
# CS_PASSWORD        - code-server password (required)
# CS_PORT            - code-server listen port (default: 8080)
ENV TUNNEL_TOKEN="" \
    SSH_PASSWORD="" \
    SSH_AUTHORIZED_KEYS="" \
    CS_PASSWORD="" \
    CS_PORT="8080"

COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD curl -fsS -o /dev/null http://localhost:${CS_PORT}/healthz && nc -z localhost 22 || exit 1

ENTRYPOINT ["/entry.sh"]
