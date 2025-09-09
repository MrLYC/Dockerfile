#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

exec client \
    --localaddr "${LOCALADDR}" \
    --remoteaddr "${REMOTEADDR}" \
    --key "${KEY}" \
    --crypt "${CRYPT}" \
    --mode "${MODE}" \
    --conn "${CONN}" \
    --autoexpire "${AUTOEXPIRE}" \
    --mtu "${MTU}" \
    --sndwnd "${SNDWND}" \
    --rcvwnd "${RCVWND}" \
    --datashard "${DATASHARD}" \
    --parityshard "${PARITYSHARD}" \
    --dscp "${DSCP}"
