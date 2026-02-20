#!/bin/bash
set -e

if [ -z "${TUNNEL_TOKEN}" ]; then
    echo "❌ Error: TUNNEL_TOKEN is required"
    echo "Get it from the Cloudflare Zero Trust dashboard or by running 'cloudflared tunnel token <tunnel-name>'"
    exit 1
fi

if [ -z "${CS_PASSWORD}" ]; then
    echo "❌ Error: CS_PASSWORD is required"
    exit 1
fi

if [ -z "${SSH_PASSWORD}" ] && [ -z "${SSH_AUTHORIZED_KEYS}" ]; then
    echo "❌ Error: At least one of SSH_PASSWORD or SSH_AUTHORIZED_KEYS is required"
    exit 1
fi

CS_PORT=${CS_PORT:-8080}

if [ -n "${SSH_PASSWORD}" ]; then
    echo "coder:${SSH_PASSWORD}" | chpasswd
    sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
fi

if [ -n "${SSH_AUTHORIZED_KEYS}" ]; then
    mkdir -p /home/coder/.ssh
    chmod 700 /home/coder/.ssh
    echo "${SSH_AUTHORIZED_KEYS}" > /home/coder/.ssh/authorized_keys
    chmod 600 /home/coder/.ssh/authorized_keys
    chown -R coder:coder /home/coder/.ssh
fi

echo "🚀 Starting SSH server..."
/usr/sbin/sshd -D &
SSHD_PID=$!

echo "🖥️ Starting code-server on port ${CS_PORT}..."
PASSWORD="${CS_PASSWORD}" code-server \
    --bind-addr "0.0.0.0:${CS_PORT}" \
    --auth password \
    --disable-telemetry &
CODE_SERVER_PID=$!

echo "🌐 Starting Cloudflare Tunnel..."
cloudflared tunnel --no-autoupdate run --token "${TUNNEL_TOKEN}" &
CLOUDFLARED_PID=$!

PIDS=("$SSHD_PID" "$CODE_SERVER_PID" "$CLOUDFLARED_PID")

trap 'echo "Signal received, stopping services..."; kill "${PIDS[@]}" 2>/dev/null; wait "${PIDS[@]}" 2>/dev/null; exit 0' TERM INT

echo "✅ All services started (SSHD=${SSHD_PID}, CODE_SERVER=${CODE_SERVER_PID}, CLOUDFLARED=${CLOUDFLARED_PID})"

set +e
wait -n "${PIDS[@]}"
EXIT_CODE=$?
echo "❌ A service exited with status ${EXIT_CODE}, stopping remaining services..."
kill "${PIDS[@]}" 2>/dev/null
wait "${PIDS[@]}" 2>/dev/null
exit "${EXIT_CODE}"
