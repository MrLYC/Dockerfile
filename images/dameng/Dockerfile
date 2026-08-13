FROM ubuntu:22.04

LABEL org.opencontainers.image.title="Dameng DM8" \
      org.opencontainers.image.description="Dameng DM8 database for Ubuntu 22.04 x86_64" \
      org.opencontainers.image.vendor="Dameng"

ARG DEBIAN_FRONTEND=noninteractive
ARG DM_PACKAGE_URL="https://download.dameng.com/eco/adapter/DM8/202605/dm8_20260428_x86_Ubuntu22_64.zip"

ENV TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DM_HOME=/home/dmdba/dmdbms

ENV PATH="${DM_HOME}/bin:${PATH}" \
    LD_LIBRARY_PATH="${DM_HOME}/bin"

# DM8's Ubuntu 22 package is an x86_64 package. Keep the image aligned with
# the package architecture; the GitHub Actions workflow publishes amd64 only.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        gosu \
        libaio1 \
        libncurses5 \
        libnsl2 \
        p7zip-full \
        tzdata \
        unzip \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --gid 2001 dinstall \
    && useradd --uid 2001 --gid 2001 --create-home --home-dir /home/dmdba --shell /bin/bash dmdba \
    && install -d -o dmdba -g dinstall -m 0755 /dmdata/data /dmdata/arch /dmdata/dmbak \
    && install -d -o dmdba -g dinstall -m 0700 /home/dmdba/dm-install-tmp \
    && printf '%s\n' \
        'dmdba soft nice 0' \
        'dmdba hard nice 0' \
        'dmdba soft as unlimited' \
        'dmdba hard as unlimited' \
        'dmdba soft fsize unlimited' \
        'dmdba hard fsize unlimited' \
        'dmdba soft nproc 65536' \
        'dmdba hard nproc 65536' \
        'dmdba soft nofile 65536' \
        'dmdba hard nofile 65536' \
        'dmdba soft core unlimited' \
        'dmdba hard core unlimited' \
        'dmdba soft data unlimited' \
        'dmdba hard data unlimited' \
        > /etc/security/limits.d/dmdba.conf

COPY dm-install.xml /opt/dm-install.xml

# The official download is a ZIP containing an ISO. Extract only DMInstall.bin
# and remove the 1+ GiB installation media after the silent installation so it
# does not remain in the final image layer.
RUN set -eux; \
    work_dir="$(mktemp -d /tmp/dm-download.XXXXXX)"; \
    trap 'rm -rf "$work_dir"' EXIT; \
    header_file="$work_dir/headers"; \
    curl --fail --silent --show-error --location \
        --retry 5 --retry-delay 5 --retry-all-errors \
        --range 0-0 --dump-header "$header_file" \
        "$DM_PACKAGE_URL" --output /dev/null; \
    total_size="$(grep -i '^content-range:' "$header_file" | tail -n 1 | awk -F/ '{print $2}' | tr -d '\r')"; \
    case "$total_size" in \
        ''|*[!0-9]*) echo "unable to determine DM package size from Content-Range" >&2; exit 1 ;; \
    esac; \
    : > "$work_dir/dm8.zip"; \
    chunk_size=$((16 * 1024 * 1024)); \
    start=0; \
    while [ "$start" -lt "$total_size" ]; do \
        end=$((start + chunk_size - 1)); \
        if [ "$end" -ge "$total_size" ]; then end=$((total_size - 1)); fi; \
        part_file="$work_dir/part-$start"; \
        curl --fail --silent --show-error --location \
            --retry 5 --retry-delay 5 --retry-all-errors \
            --range "$start-$end" "$DM_PACKAGE_URL" --output "$part_file"; \
        expected_size=$((end - start + 1)); \
        actual_size="$(stat -c '%s' "$part_file")"; \
        if [ "$actual_size" -ne "$expected_size" ]; then \
            echo "unexpected DM package chunk size: expected $expected_size, got $actual_size" >&2; \
            exit 1; \
        fi; \
        cat "$part_file" >> "$work_dir/dm8.zip"; \
        rm -f "$part_file"; \
        start=$((end + 1)); \
    done; \
    test "$(stat -c '%s' "$work_dir/dm8.zip")" -eq "$total_size"; \
    unzip -tq "$work_dir/dm8.zip"; \
    mkdir "$work_dir/zip" "$work_dir/media"; \
    unzip -q "$work_dir/dm8.zip" -d "$work_dir/zip"; \
    iso_file="$(find "$work_dir/zip" -maxdepth 1 -type f -iname '*.iso' -print -quit)"; \
    test -n "$iso_file"; \
    7z x -bd -y "$iso_file" "-o$work_dir/media" >/dev/null; \
    test -f "$work_dir/media/DMInstall.bin"; \
    install -o dmdba -g dinstall -m 0755 "$work_dir/media/DMInstall.bin" /opt/DMInstall.bin; \
    chown dmdba:dinstall /opt/dm-install.xml; \
    gosu dmdba env DM_INSTALL_TMPDIR=/home/dmdba/dm-install-tmp \
        /opt/DMInstall.bin -q /opt/dm-install.xml; \
    test -x "$DM_HOME/bin/dmserver"; \
    chown -R dmdba:dinstall "$DM_HOME"; \
    rm -rf /opt/DMInstall.bin /opt/dm-install.xml /home/dmdba/dm-install-tmp

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY docker-healthcheck.sh /usr/local/bin/docker-healthcheck.sh
RUN chmod 0755 /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-healthcheck.sh

WORKDIR /home/dmdba

EXPOSE 5236
VOLUME ["/dmdata"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=5 \
    CMD ["/usr/local/bin/docker-healthcheck.sh"]

STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
