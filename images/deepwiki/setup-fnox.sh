#!/usr/bin/env bash

set -euo pipefail

fnox_dir="${FNOX_HOME:-/root/.config/fnox}"
config_file="${fnox_dir}/fnox.toml"
age_key_file="${fnox_dir}/age.txt"

mkdir -p "${fnox_dir}"
rm -f "${config_file}"

fnox init --config "${config_file}"

if [[ ! -f "${age_key_file}" ]]; then
    age-keygen -o "${age_key_file}" >/dev/null
fi

public_key=""
while IFS= read -r line; do
    case "${line}" in
        *"public key:"*)
            public_key="${line##*: }"
            break
            ;;
    esac
done < "${age_key_file}"

if [[ -z "${public_key}" ]]; then
    echo "Failed to extract fnox age public key" >&2
    exit 1
fi

cat >> "${config_file}" <<EOF

[providers.age]
type = "age"
recipients = ["${public_key}"]
EOF

secret_key=""
while IFS= read -r line; do
    case "${line}" in
        AGE-SECRET-KEY-*)
            secret_key="${line}"
            break
            ;;
    esac
done < "${age_key_file}"

if [[ -z "${secret_key}" ]]; then
    echo "Failed to extract fnox age secret key" >&2
    exit 1
fi
