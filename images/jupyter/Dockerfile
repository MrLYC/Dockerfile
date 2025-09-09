# Modern Jupyter Data Science Environment
FROM jupyter/datascience-notebook:latest

LABEL maintainer="lyc <imyikong@gmail.com>"
LABEL description="Enhanced Jupyter data science environment with additional packages"
LABEL version="2.0"

# Switch to root to install system packages
USER root

# Install additional system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        htop \
        tree \
        curl \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to jovyan user
USER ${NB_UID}

# Install additional Python packages
RUN pip install --no-cache-dir \
    ipympl \
    plotly \
    bokeh \
    streamlit \
    fastapi \
    uvicorn \
    requests \
    beautifulsoup4 \
    sqlalchemy \
    pymongo \
    redis \
    celery \
    jupyterlab-git \
    nbconvert \
    voila

# Install JupyterLab extensions
RUN jupyter labextension install --no-build \
    @jupyter-widgets/jupyterlab-manager \
    plotlywidget && \
    jupyter lab build && \
    jupyter lab clean && \
    npm cache clean --force

# Environment variables
ENV DOCKER_DEBUG=0
ENV JUPYTER_TOKEN=""
ENV JUPYTER_PASSWORD=""
ENV NOTEBOOK_DIR="/home/jovyan/work"

# Copy entrypoint
COPY --chown=${NB_UID}:${NB_GID} entry.sh /entry.sh
RUN chmod +x /entry.sh

# Create work directory
RUN mkdir -p ${NOTEBOOK_DIR} && \
    chown ${NB_UID}:${NB_GID} ${NOTEBOOK_DIR}

# Expose Jupyter port
EXPOSE 8888

# Volume for notebooks
VOLUME ["${NOTEBOOK_DIR}"]

# Working directory
WORKDIR ${NOTEBOOK_DIR}

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8888/api || exit 1

# Entrypoint
ENTRYPOINT ["/entry.sh"]
