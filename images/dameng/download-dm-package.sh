#!/usr/bin/env bash

set -Eeuo pipefail

if (( $# != 2 )); then
    echo "usage: $0 PACKAGE_URL OUTPUT_FILE" >&2
    exit 2
fi

package_url="$1"
output_file="$2"

: "${DM_PROXY_MAX_CANDIDATES:=40}"
: "${DM_PROXY_LIST_URLS:=}"
: "${DM_PROXY_PROBE_TIMEOUT:=20}"
: "${DM_PROXY_CONNECT_TIMEOUT:=10}"
: "${DM_PROXY_DOWNLOAD_TIMEOUT:=1800}"
: "${DM_PROXY_SPEED_LIMIT:=16384}"
: "${DM_PROXY_SPEED_TIME:=120}"
: "${DM_PACKAGE_SHA256:=}"

for command_name in awk curl grep head install sed sha256sum shuf sort stat tr unzip wc; do
    command -v "$command_name" >/dev/null 2>&1 || {
        echo "required command is missing: $command_name" >&2
        exit 1
    }
done

if [[ ! "$DM_PROXY_MAX_CANDIDATES" =~ ^[1-9][0-9]*$ ]]; then
    echo "DM_PROXY_MAX_CANDIDATES must be a positive integer" >&2
    exit 2
fi

work_dir="$(mktemp -d /tmp/dm-proxy-download.XXXXXX)"
trap 'rm -rf "$work_dir"' EXIT

candidate_file="$work_dir/candidates"
: > "$candidate_file"

if [[ -n "$DM_PROXY_LIST_URLS" ]]; then
    mapfile -t source_specs < <(printf '%s\n' "$DM_PROXY_LIST_URLS")
else
    # The first field is the proxy protocol used by curl.  The HTTP/HTTPS
    # lists contain HTTP CONNECT proxies, while the SOCKS5 lists use DNS
    # resolution through the proxy.
    source_specs=(
        "http|https://cdn.jsdelivr.net/gh/proxyscrape/free-proxy-list@main/proxies/countries/cn/http/data.txt"
        "http|https://cdn.jsdelivr.net/gh/proxyscrape/free-proxy-list@main/proxies/countries/cn/https/data.txt"
        "socks5h|https://cdn.jsdelivr.net/gh/proxyscrape/free-proxy-list@main/proxies/countries/cn/socks5/data.txt"
        "http|https://cdn.jsdelivr.net/gh/proxyscrape/free-proxy-list@main/proxies/protocols/http/data.txt"
        "http|https://cdn.jsdelivr.net/gh/proxyscrape/free-proxy-list@main/proxies/protocols/https/data.txt"
        "socks5h|https://cdn.jsdelivr.net/gh/proxyscrape/free-proxy-list@main/proxies/protocols/socks5/data.txt"
        "http|https://databay.com/api/v1/proxy-list?protocol=http&country=cn&ssl=strict&format=txt&limit=1000"
        "socks5h|https://databay.com/api/v1/proxy-list?protocol=socks5&country=cn&ssl=strict&format=txt&limit=1000"
        "http|https://cdn.jsdelivr.net/gh/databay-labs/free-proxy-list/by-country/cn/http.txt"
        "http|https://cdn.jsdelivr.net/gh/databay-labs/free-proxy-list/http.txt"
        "socks5h|https://cdn.jsdelivr.net/gh/databay-labs/free-proxy-list/by-country/cn/socks5.txt"
        "socks5h|https://cdn.jsdelivr.net/gh/databay-labs/free-proxy-list/socks5.txt"
        # Proxy5's free-China page is included as a best-effort HTML source;
        # DM_PROXY_LIST_URLS can override it with its TXT export if needed.
        "http|https://proxy5.net/free-proxy/china"
    )
fi

source_index=0
for source_spec in "${source_specs[@]}"; do
    [[ -z "$source_spec" ]] && continue

    if [[ "$source_spec" != *'|'* ]]; then
        echo "ignoring malformed proxy source (expected protocol|URL)" >&2
        continue
    fi

    proxy_scheme="${source_spec%%|*}"
    source_url="${source_spec#*|}"
    if [[ ! "$proxy_scheme" =~ ^(http|socks5h)$ ]] || [[ ! "$source_url" =~ ^https:// ]]; then
        echo "ignoring unsafe proxy source: $proxy_scheme" >&2
        continue
    fi

    source_index=$((source_index + 1))
    source_file="$work_dir/source-$source_index"
    echo "fetching proxy source $source_index" >&2
    if ! curl --fail --silent --show-error --location \
        --connect-timeout 10 --max-time 45 --retry 2 --retry-delay 2 \
        --retry-all-errors "$source_url" --output "$source_file"; then
        echo "proxy source $source_index was unavailable" >&2
        continue
    fi

    # Accept plain-text lists, JSON, and the Proxy5 HTML page, but only keep
    # syntactically valid public IPv4 endpoints. Never execute list content.
    grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]{1,5}' "$source_file" 2>/dev/null \
        | awk -F: -v scheme="$proxy_scheme" '
            {
                parts = split($1, octets, ".")
                if (parts != 4 || $2 < 1 || $2 > 65535) next
                valid = 1
                for (i = 1; i <= 4; i++) {
                    if (octets[i] !~ /^[0-9]+$/ || octets[i] > 255) valid = 0
                }
                if (!valid) next
                if (octets[1] == 0 || octets[1] == 10 || octets[1] == 127) next
                if (octets[1] == 169 && octets[2] == 254) next
                if (octets[1] == 172 && octets[2] >= 16 && octets[2] <= 31) next
                if (octets[1] == 192 && octets[2] == 168) next
                print scheme "://" $0
            }
        ' >> "$candidate_file" || true
done

sort -u "$candidate_file" -o "$candidate_file"
candidate_count="$(wc -l < "$candidate_file" | tr -d '[:space:]')"
if [[ "$candidate_count" -eq 0 ]]; then
    echo "proxy sources returned no usable public IPv4 endpoints" >&2
    exit 1
fi

shuf -n "$DM_PROXY_MAX_CANDIDATES" "$candidate_file" > "$work_dir/shuffled-candidates"
selected_count="$(wc -l < "$work_dir/shuffled-candidates" | tr -d '[:space:]')"

probe_proxy() {
    local proxy="$1"
    local header_file="$work_dir/probe-headers"
    local probe_file="$work_dir/probe-body"
    local total_size
    local probe_size

    rm -f "$header_file" "$probe_file"
    if ! curl --fail --silent --show-error --location \
        --proxy "$proxy" --noproxy '' \
        --connect-timeout "$DM_PROXY_CONNECT_TIMEOUT" \
        --max-time "$DM_PROXY_PROBE_TIMEOUT" --max-filesize 1048576 \
        --retry 1 --retry-delay 1 --retry-all-errors \
        --range 0-0 --dump-header "$header_file" \
        "$package_url" --output "$probe_file"; then
        return 1
    fi

    probe_size="$(stat -c '%s' "$probe_file")"
    [[ "$probe_size" -eq 1 ]] || return 1

    total_size="$(grep -i '^content-range:' "$header_file" | tail -n 1 \
        | sed -E 's#.*\/([0-9]+)[[:space:]]*\r?$#\1#')"
    [[ "$total_size" =~ ^[1-9][0-9]*$ ]] || return 1

    printf '%s\n' "$total_size"
}

download_with_proxy() {
    local proxy="$1"
    local expected_size="$2"
    local partial_file="$work_dir/dm8.zip.partial"
    local actual_size

    rm -f "$partial_file"
    if ! curl --fail --silent --show-error --location \
        --proxy "$proxy" --noproxy '' \
        --connect-timeout "$DM_PROXY_CONNECT_TIMEOUT" \
        --max-time "$DM_PROXY_DOWNLOAD_TIMEOUT" \
        --speed-limit "$DM_PROXY_SPEED_LIMIT" \
        --speed-time "$DM_PROXY_SPEED_TIME" \
        --retry 2 --retry-delay 5 --retry-all-errors \
        "$package_url" --output "$partial_file"; then
        return 1
    fi

    actual_size="$(stat -c '%s' "$partial_file")"
    [[ "$actual_size" -eq "$expected_size" ]] || {
        echo "proxy returned an incomplete package ($actual_size/$expected_size bytes)" >&2
        return 1
    }

    [[ "$(head -c 2 "$partial_file")" == "PK" ]] || {
        echo "proxy returned a non-ZIP response" >&2
        return 1
    }
    unzip -tq "$partial_file" >/dev/null

    if [[ -n "$DM_PACKAGE_SHA256" ]]; then
        printf '%s  %s\n' "$DM_PACKAGE_SHA256" "$partial_file" | sha256sum -c -
    fi

    install -D -m 0644 "$partial_file" "$output_file"
}

attempt=0
while IFS= read -r proxy; do
    [[ -z "$proxy" ]] && continue
    attempt=$((attempt + 1))
    echo "testing proxy $attempt/$selected_count" >&2

    if ! expected_size="$(probe_proxy "$proxy")"; then
        echo "proxy $attempt failed the ranged HTTPS probe" >&2
        continue
    fi

    echo "proxy $attempt accepted the official package endpoint" >&2
    if download_with_proxy "$proxy" "$expected_size"; then
        echo "DM8 package downloaded and verified through proxy $attempt" >&2
        exit 0
    fi
    echo "proxy $attempt failed the complete package download" >&2
done < "$work_dir/shuffled-candidates"

echo "all selected free proxies failed to download the DM8 package" >&2
exit 1
