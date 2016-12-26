#!/bin/sh

set -x

apk update
apk add --no-cache \
    wget \
    ;

wget https://dl.minio.io/server/minio/release/linux-amd64/minio -O minio
chmod 777 minio
mv minio /usr/local/bin/

rm -f /build.sh || true
rm -rf /go/pkg /go/src
adk del \
    wget \
    ;
rm -rf /var/cache/apk/*
