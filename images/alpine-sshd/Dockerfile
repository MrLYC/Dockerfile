# Alpine Linux SSH Server with modern security practices
FROM alpine:3.18

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="Lightweight SSH server based on Alpine Linux"
LABEL version="2.0"

# Install SSH server and dependencies
RUN apk update && \
    apk add --no-cache \
        openssh \
        sudo \
        shadow && \
    # Configure SSH for security
    sed -i 's/#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#*PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#*AuthorizedKeysFile.*/AuthorizedKeysFile .ssh\/authorized_keys/' /etc/ssh/sshd_config && \
    # Clean up
    rm -rf /var/cache/apk/* && \
    # Generate host keys
    ssh-keygen -A

# Create non-root user for SSH access
RUN addgroup -g 1001 -S sshuser && \
    adduser -S sshuser -u 1001 -G sshuser -s /bin/sh

# Environment variables
ENV DOCKER_DEBUG=0
ENV AUTHORIZED_KEYS=""
ENV AUTH_PASSWORD=""
ENV SSH_USER="sshuser"

# Copy entrypoint script
COPY entry.sh /entry.sh
RUN chmod +x /entry.sh

# Expose SSH port
EXPOSE 22

# Set working directory
WORKDIR /home/sshuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD nc -z localhost 22 || exit 1

# Use entrypoint
ENTRYPOINT ["/entry.sh"]
