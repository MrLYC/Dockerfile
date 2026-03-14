#!/usr/bin/env bash

set -euo pipefail

load_default_fnox_age_key() {
    if [[ -n "${FNOX_AGE_KEY:-}" ]]; then
        return 0
    fi

    local key_file="${FNOX_AGE_KEY_PATH:-/root/.config/fnox/age.txt}"
    if [[ ! -f "${key_file}" ]]; then
        return 0
    fi

    local line
    while IFS= read -r line; do
        case "${line}" in
            AGE-SECRET-KEY-*)
                export FNOX_AGE_KEY="${line}"
                return 0
                ;;
        esac
    done < "${key_file}"
}

load_default_fnox_age_key

if [[ $# -gt 0 ]]; then
    exec "$@"
fi

export CHROME_BIN="${CHROME_BIN:-/usr/bin/chromium}"

exec /usr/local/bin/mise -C /mise run --no-prepare deepwiki
