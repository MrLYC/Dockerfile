FROM debian:12-slim

ARG proxy

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
ENV MISE_HTTP_TIMEOUT=120
# ENV MISE_VERSION="..."

ADD mise.toml /mise/config.toml

RUN if [ -n "$proxy" ]; then \
        export http_proxy="$proxy" https_proxy="$proxy" HTTP_PROXY="$proxy" HTTPS_PROXY="$proxy"; \
    fi \
    && curl https://mise.run | bash \
    && echo "eval \"\$(/usr/local/bin/mise activate bash)\"" >> /root/.bashrc \
    && mise install \
    && mise doctor \
    && mise cache clear -y

ADD build.sh /build.sh

RUN /build.sh

CMD ["bash"]
