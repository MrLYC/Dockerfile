#!/bin/bash
set -e

if [ -z "${TUNNEL_TOKEN}" ]; then
    echo "❌ Error: TUNNEL_TOKEN is required"
    echo "Get it from Cloudflare Zero Trust dashboard or 'cloudflared tunnel create'"
    exit 1
fi

SSH_PASSWORD=${SSH_PASSWORD:-changeme}
CS_PASSWORD=${CS_PASSWORD:-changeme}
CS_PORT=${CS_PORT:-8080}

echo "root:${SSH_PASSWORD}" | chpasswd

sed -i "s/#*Port .*/Port 22/" /etc/ssh/sshd_config

echo "🚀 Starting SSH server..."
/usr/sbin/sshd

echo "🖥️ Starting code-server on port ${CS_PORT}..."
PASSWORD="${CS_PASSWORD}" code-server \
    --bind-addr "0.0.0.0:${CS_PORT}" \
    --auth password \
    --disable-telemetry &

echo "🌐 Starting Cloudflare Tunnel..."
exec cloudflared tunnel --no-autoupdate run --token "${TUNNEL_TOKEN}"
