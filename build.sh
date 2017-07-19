#!/bin/sh

set -x
apk update

apk info | xargs -i apk del {}
rm -rf /var/cache/apk/*
rm -f /build.sh || true
