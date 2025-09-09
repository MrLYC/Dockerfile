#!/bin/sh

set -x

export GOPATH="/go"
mkdir -p ${GOPATH}

apk update
apk add git go mysql-client
go get github.com/lisijie/webcron
apk clean

apk del go git
rm -rf ${GOPATH}
rm -rf /var/cache/apk/*
rm -f /build.sh || true
