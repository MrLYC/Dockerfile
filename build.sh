#!/bin/sh

set -x
apk update

apk add g++ curl curl-dev libxml2-dev libxslt-dev openssl

curl -Ls "https://github.com/dustinblackman/phantomized/releases/download/2.1.1a/dockerized-phantomjs.tar.gz" | tar xz -C /

export PYCURL_SSL_LIBRARY=openssl
pip install pyspider

apk del g++ curl

rm -rf /var/cache/apk/*
rm -f /build.sh || true
