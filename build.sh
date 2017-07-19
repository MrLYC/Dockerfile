#!/bin/sh

set -x
apk update

rm -rf /var/cache/apk/*
rm -f /build.sh || true
apk info | grep -v apk | xargs -i apk del {} || true
