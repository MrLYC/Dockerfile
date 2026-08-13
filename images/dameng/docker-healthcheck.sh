#!/usr/bin/env bash

set -Eeuo pipefail

exec 3<>"/dev/tcp/127.0.0.1/${DM_PORT:-5236}"
