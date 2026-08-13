#!/usr/bin/env bash

set -Eeuo pipefail

if (( $# != 1 )); then
    echo "usage: $0 IMAGE_DIRECTORY" >&2
    exit 2
fi

image_dir="$1"
config_file="$image_dir/build.env"
platforms="linux/amd64,linux/arm64"

if [[ ! -d "$image_dir" ]]; then
    echo "image directory does not exist: $image_dir" >&2
    exit 1
fi

if [[ -f "$config_file" ]]; then
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="$(printf '%s' "${line%%#*}" | sed \
            -e 's/^[[:space:]]*//' \
            -e 's/[[:space:]]*$//')"

        [[ -z "$line" ]] && continue

        if [[ "$line" != PLATFORMS=* ]]; then
            echo "unsupported setting in $config_file: $line" >&2
            exit 1
        fi

        platforms="${line#PLATFORMS=}"
    done < "$config_file"
fi

if [[ ! "$platforms" =~ ^linux/[a-z0-9._-]+(/[a-z0-9._-]+)?(,linux/[a-z0-9._-]+(/[a-z0-9._-]+)?)*$ ]]; then
    echo "invalid PLATFORMS in $config_file: $platforms" >&2
    exit 1
fi

printf 'platforms=%s\n' "$platforms"
