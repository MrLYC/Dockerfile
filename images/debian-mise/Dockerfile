FROM debian:12-slim

RUN apt-get update  \
    && apt-get -y --no-install-recommends install \
        sudo curl git ca-certificates build-essential bash \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"
# ENV MISE_VERSION="..."

ADD mise.toml /mise/config.toml

RUN curl https://mise.run | bash \
    && echo "eval \"\$(/usr/local/bin/mise activate bash)\"" >> /root/.bashrc \
    && mise install

CMD ["bash"]
