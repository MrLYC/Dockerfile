#!/bin/sh

set -x
apk update

apk add net-snmp 

rm -rf /var/cache/apk/*
rm -f /build.sh || true