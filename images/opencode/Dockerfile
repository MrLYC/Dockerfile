FROM debian:12-slim

ARG proxy

RUN apt-get update  \
    && apt-get -y --no-install-recommends install \
        sudo curl git ca-certificates build-essential bash \
    && rm -rf /var/lib/apt/lists/*

# 创建非 root 用户
RUN groupadd -g 1001 app && \
    useradd -m -u 1001 -g app -s /bin/bash app && \
    echo "app ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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
    && echo "eval \"\$(/usr/local/bin/mise activate bash)\"" >> /home/app/.bashrc \
    && mise install \
    && mise doctor \
    && mise cache clear -y

ADD build.sh /build.sh

# 在切换用户前，确保 mise 目录权限正确
RUN chown -R app:app /mise

# 切换到 app 用户执行构建脚本
USER app
RUN bash /build.sh

WORKDIR /home/app/project

CMD ["opencode"]
