#!/bin/bash

# Enable debug mode if requested
if [ "${DOCKER_DEBUG}" == "1" ]; then
    set -x
fi

# Set default values
NOTEBOOK_DIR=${NOTEBOOK_DIR:-"/home/jovyan/work"}
JUPYTER_PORT=${JUPYTER_PORT:-8888}

# Prepare Jupyter arguments
JUPYTER_ARGS=(
    "--notebook-dir=${NOTEBOOK_DIR}"
    "--ip=0.0.0.0"
    "--port=${JUPYTER_PORT}"
    "--no-browser"
    "--allow-root"
    "--NotebookApp.open_browser=False"
    "--NotebookApp.allow_remote_access=True"
)

# Configure authentication
if [[ -n "${JUPYTER_TOKEN}" ]]; then
    JUPYTER_ARGS+=("--NotebookApp.token=${JUPYTER_TOKEN}")
    echo "🔐 Jupyter token authentication enabled"
elif [[ -n "${JUPYTER_PASSWORD}" ]]; then
    # Generate password hash
    PASSWORD_HASH=$(python -c "from notebook.auth import passwd; print(passwd('${JUPYTER_PASSWORD}'))")
    JUPYTER_ARGS+=("--NotebookApp.password=${PASSWORD_HASH}")
    echo "🔐 Jupyter password authentication enabled"
else
    # No authentication - only for development
    JUPYTER_ARGS+=("--NotebookApp.token=''")
    JUPYTER_ARGS+=("--NotebookApp.password=''")
    echo "⚠️  Jupyter running without authentication (development mode)"
fi

# Ensure notebook directory exists and has correct permissions
mkdir -p "${NOTEBOOK_DIR}"

echo "🚀 Starting Jupyter Lab..."
echo "📂 Notebook directory: ${NOTEBOOK_DIR}"
echo "🌐 Port: ${JUPYTER_PORT}"
echo "📝 Access: http://localhost:${JUPYTER_PORT}"

# Start Jupyter Lab
exec /opt/conda/bin/jupyter lab "${JUPYTER_ARGS[@]}"
