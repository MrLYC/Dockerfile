#!/bin/sh

# Enable debug mode if requested
if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

# Ensure host keys exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Configure SSH user
SSH_USER=${SSH_USER:-sshuser}

# Setup authorized keys for SSH user
if [[ "${AUTHORIZED_KEYS}" != "" ]]; then
    USER_HOME="/home/${SSH_USER}"
    mkdir -p "${USER_HOME}/.ssh"
    chmod 700 "${USER_HOME}/.ssh"
    echo "${AUTHORIZED_KEYS}" > "${USER_HOME}/.ssh/authorized_keys"
    chmod 600 "${USER_HOME}/.ssh/authorized_keys"
    chown -R "${SSH_USER}:${SSH_USER}" "${USER_HOME}/.ssh"
    echo "✓ SSH public key authentication configured for user: ${SSH_USER}"
fi

# Setup password authentication if requested (not recommended)
if [[ "${AUTH_PASSWORD}" != "" ]]; then
    echo "${SSH_USER}:${AUTH_PASSWORD}" | chpasswd
    sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    echo "⚠️  Password authentication enabled for user: ${SSH_USER}"
    echo "⚠️  Consider using public key authentication instead"
fi

# Ensure SSH user can login
if [[ "${AUTHORIZED_KEYS}" == "" && "${AUTH_PASSWORD}" == "" ]]; then
    echo "❌ Error: No authentication method configured!"
    echo "Please set either AUTHORIZED_KEYS or AUTH_PASSWORD environment variable"
    exit 1
fi

echo "🚀 Starting SSH server..."
echo "👤 SSH user: ${SSH_USER}"
echo "🔒 Root login: disabled"
echo "🔑 Public key auth: enabled"

# Start SSH daemon
exec /usr/sbin/sshd -D
