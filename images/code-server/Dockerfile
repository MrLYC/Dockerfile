FROM debian:12-slim

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="code-server with dev extensions and Cloudflare Tunnel"

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    curl \
    ca-certificates \
    git \
    sudo \
    wget \
    gnupg \
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

RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN mkdir -p /run/sshd \
    && sed -i 's/#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && ssh-keygen -A

RUN code-server \
    --install-extension golang.go \
    --install-extension ms-python.python \
    --install-extension dbaeumer.vscode-eslint \
    --install-extension esbenp.prettier-vscode \
    --install-extension yzhang.markdown-all-in-one \
    --install-extension GitHub.copilot \
    --install-extension GitHub.copilot-chat \
    --install-extension opencode.opencode \
    || true

# TUNNEL_TOKEN       - Cloudflare Tunnel token (required)
# SSH_PASSWORD       - Root SSH password (default: changeme)
# CS_PASSWORD        - code-server password (default: changeme)
# CS_PORT            - code-server listen port (default: 8080)
ENV TUNNEL_TOKEN="" \
    SSH_PASSWORD="changeme" \
    CS_PASSWORD="changeme" \
    CS_PORT="8080"

COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD pgrep cloudflared > /dev/null && pgrep code-server > /dev/null || exit 1

ENTRYPOINT ["/entry.sh"]
