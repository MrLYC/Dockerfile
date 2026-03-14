#!/usr/bin/env bash

set -euo pipefail

fnox_bin="${FNOX_BIN:-/usr/local/bin/fnox}"
fnox_config_file="${FNOX_CONFIG_FILE:-/root/.config/fnox/fnox.toml}"

lookup_env_alias() {
    local alias_name="$1"
    local line

    while IFS= read -r line; do
        case "${line}" in
            "${alias_name}"=*)
                printf '%s' "${line#*=}"
                return 0
                ;;
        esac
    done < <(env)

    return 1
}

lookup_fnox_secret() {
    local secret_name="$1"

    if "${fnox_bin}" -c "${fnox_config_file}" get "${secret_name}" >/dev/null 2>&1; then
        "${fnox_bin}" -c "${fnox_config_file}" get "${secret_name}"
        return 0
    fi

    return 1
}

resolve_value() {
    local env_name="$1"
    local alias_name="$2"
    local default_value="${3:-}"

    if [[ -n "${!env_name:-}" ]]; then
        printf '%s' "${!env_name}"
        return 0
    fi

    if lookup_env_alias "${alias_name}"; then
        return 0
    fi

    if lookup_fnox_secret "${env_name}"; then
        return 0
    fi

    if lookup_fnox_secret "${alias_name}"; then
        return 0
    fi

    printf '%s' "${default_value}"
}

require_value() {
    local key_name="$1"
    local value="$2"

    if [[ -z "${value}" ]]; then
        echo "Missing required value for ${key_name}" >&2
        exit 1
    fi
}

redact_value() {
    local value="$1"
    if [[ -z "${value}" ]]; then
        printf '(empty)'
        return 0
    fi

    if [[ ${#value} -le 4 ]]; then
        printf '****'
        return 0
    fi

    printf '%s****' "${value:0:4}"
}

llm_provider="$(resolve_value "LLM_PROVIDER" "llm-provider" "openai")"
llm_base_url="$(resolve_value "LLM_BASE_URL" "llm-base-url")"
llm_api_key="$(resolve_value "LLM_API_KEY" "llm-api-key")"
llm_model="$(resolve_value "LLM_MODEL" "llm-model")"
input_dir="$(resolve_value "INPUT_DIR" "input-dir" "/workspace/input")"
output_dir="$(resolve_value "OUTPUT_DIR" "output-dir" "/workspace/output")"
target_language="$(resolve_value "TARGET_LANGUAGE" "target-language")"
disable_preset_tools="$(resolve_value "DEEPWIKI_DISABLE_PRESET_TOOLS" "deepwiki-disable-preset-tools" "false")"

require_value "LLM_MODEL" "${llm_model}"
require_value "LLM_API_KEY" "${llm_api_key}"

if [[ ! -d "${input_dir}" ]]; then
    echo "Input directory does not exist: ${input_dir}" >&2
    exit 1
fi

mkdir -p "${output_dir}"

echo "[deepwiki] provider=${llm_provider} model=${llm_model}"
echo "[deepwiki] base_url=${llm_base_url:-<default>} api_key=$(redact_value "${llm_api_key}")"
echo "[deepwiki] input=${input_dir} output=${output_dir}"

deepwiki_args=(
    -p "${input_dir}"
    -o "${output_dir}"
    --llm-api-key "${llm_api_key}"
    --model-efficient "${llm_model}"
)

if [[ -n "${llm_base_url}" ]]; then
    deepwiki_args+=(--llm-api-base-url "${llm_base_url}")
fi

if [[ -n "${target_language}" ]]; then
    deepwiki_args+=(--target-language "${target_language}")
fi

if [[ "${disable_preset_tools}" == "true" ]]; then
    deepwiki_args+=(--disable-preset-tools)
fi

mermaid_args=(
    -d "${output_dir}"
    --llm-provider "${llm_provider}"
    --llm-model "${llm_model}"
    --llm-api-key "${llm_api_key}"
)

if [[ -n "${llm_base_url}" ]]; then
    mermaid_args+=(--llm-base-url "${llm_base_url}")
fi

echo "[deepwiki] running deepwiki-rs"
deepwiki-rs "${deepwiki_args[@]}"

echo "[deepwiki] running mermaid-fixer"
mermaid-fixer "${mermaid_args[@]}"

echo "[deepwiki] completed successfully"
