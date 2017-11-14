#!/bin/sh

set -x
apk update

apk add g++ curl-dev libxml2-dev libxslt-dev openssl

export PYCURL_SSL_LIBRARY=openssl
pip install pyspider

apk del g++

rm -rf /var/cache/apk/*
rm -f /build.sh || true
