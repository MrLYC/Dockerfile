#!/usr/bin/env bash

set -Eeuo pipefail

DM_DATA_DIR="${DM_DATA_DIR:-/dmdata/data}"
DM_ARCH_DIR="${DM_ARCH_DIR:-/dmdata/arch}"
DM_BACKUP_DIR="${DM_BACKUP_DIR:-/dmdata/dmbak}"
DM_DB_NAME="${DM_DB_NAME:-DAMENG}"
DM_INSTANCE_NAME="${DM_INSTANCE_NAME:-DMSERVER}"
DM_PORT="${DM_PORT:-5236}"
DM_CHARSET="${DM_CHARSET:-1}"
DM_CASE_SENSITIVE="${DM_CASE_SENSITIVE:-Y}"

if [[ -n "${DM_SYSDBA_PWD_FILE:-}" ]]; then
    DM_SYSDBA_PWD="$(<"$DM_SYSDBA_PWD_FILE")"
fi

if [[ "$(id -u)" -ne 0 ]]; then
    echo "docker-entrypoint.sh must start as root so mounted data can be owned by dmdba" >&2
    exit 1
fi

if [[ ! "$DM_DB_NAME" =~ ^[A-Za-z0-9_]+$ ]]; then
    echo "DM_DB_NAME must contain only letters, digits, and underscores" >&2
    exit 1
fi

if [[ ! "$DM_PORT" =~ ^[0-9]+$ ]]; then
    echo "DM_PORT must be a numeric TCP port" >&2
    exit 1
fi

install -d -o dmdba -g dinstall -m 0755 "$DM_DATA_DIR" "$DM_ARCH_DIR" "$DM_BACKUP_DIR"

db_dir="$DM_DATA_DIR/$DM_DB_NAME"
dm_ini="$db_dir/dm.ini"

if [[ ! -f "$dm_ini" ]]; then
    if [[ -z "${DM_SYSDBA_PWD:-}" ]]; then
        echo "Set DM_SYSDBA_PWD (or DM_SYSDBA_PWD_FILE) before starting a new database" >&2
        exit 1
    fi

    echo "Initializing DM8 database ${DM_DB_NAME} on port ${DM_PORT}"
    gosu dmdba "$DM_HOME/bin/dminit" \
        "PATH=$DM_DATA_DIR" \
        "DB_NAME=$DM_DB_NAME" \
        "INSTANCE_NAME=$DM_INSTANCE_NAME" \
        "PORT_NUM=$DM_PORT" \
        "CHARSET=$DM_CHARSET" \
        "CASE_SENSITIVE=$DM_CASE_SENSITIVE" \
        "SYSDBA_PWD=$DM_SYSDBA_PWD" \
        "SYSAUDITOR_PWD=$DM_SYSDBA_PWD"
fi

if [[ ! -f "$dm_ini" ]]; then
    echo "DM8 initialization did not create $dm_ini" >&2
    exit 1
fi

chown -R dmdba:dinstall "$DM_DATA_DIR"

# Apply the limits recommended by the installation guide when the container
# runtime permits them. Docker/Kubernetes can still set stricter ulimits.
ulimit -n 65536 2>/dev/null || true
ulimit -u 65536 2>/dev/null || true

if (( $# > 0 )); then
    exec "$@"
fi

echo "Starting DM8 database ${DM_DB_NAME}"
exec gosu dmdba "$DM_HOME/bin/dmserver" "$dm_ini" -noconsole
