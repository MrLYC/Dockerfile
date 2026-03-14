FROM debian:12-slim AS builder

ARG proxy

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:/root/.cargo/bin:${PATH}"
ENV MISE_HTTP_TIMEOUT=120

COPY mise.build.toml /mise/config.toml
COPY setup-fnox.sh /tmp/setup-fnox.sh

RUN if [ -n "$proxy" ]; then \
        export http_proxy="$proxy" https_proxy="$proxy" HTTP_PROXY="$proxy" HTTPS_PROXY="$proxy"; \
    else \
        unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy NO_PROXY no_proxy; \
    fi \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        age \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        libssl-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN if [ -n "$proxy" ]; then \
        export http_proxy="$proxy" https_proxy="$proxy" HTTP_PROXY="$proxy" HTTPS_PROXY="$proxy"; \
    else \
        unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy NO_PROXY no_proxy; \
    fi \
    && curl https://mise.run | bash \
    && mise install \
    && cargo install --locked deepwiki-rs mermaid-fixer \
    && bash /tmp/setup-fnox.sh \
    && cp "$(compgen -G '/mise/installs/fnox/*/fnox' | head -n 1)" /usr/local/bin/fnox \
    && mise cache clear -y \
    && rm -f /tmp/setup-fnox.sh


FROM debian:12-slim

ARG proxy

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:${PATH}"
ENV FNOX_HOME="/root/.config/fnox"
ENV FNOX_AGE_KEY_PATH="/root/.config/fnox/age.txt"
ENV WORKDIR_ROOT="/workspace"

COPY --from=builder /usr/local/bin/mise /usr/local/bin/mise
COPY --from=builder /mise /mise
COPY --from=builder /usr/local/bin/fnox /usr/local/bin/fnox
COPY --from=builder /root/.cargo/bin/deepwiki-rs /usr/local/bin/deepwiki-rs
COPY --from=builder /root/.cargo/bin/mermaid-fixer /usr/local/bin/mermaid-fixer
COPY --from=builder /root/.config/fnox /root/.config/fnox

RUN if [ -n "$proxy" ]; then \
        export http_proxy="$proxy" https_proxy="$proxy" HTTP_PROXY="$proxy" HTTPS_PROXY="$proxy"; \
    else \
        unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY all_proxy NO_PROXY no_proxy; \
    fi \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        age \
        bash \
        ca-certificates \
        chromium \
        git \
    && rm -rf /var/lib/apt/lists/*

COPY mise.toml /mise/config.toml
COPY entry.sh /entry.sh
COPY deepwiki-task.sh /opt/deepwiki/deepwiki-task.sh

RUN chmod +x /entry.sh /opt/deepwiki/deepwiki-task.sh \
    && mkdir -p /workspace/input /workspace/output

WORKDIR /workspace

ENTRYPOINT ["/entry.sh"]
CMD []
