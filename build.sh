#!/bin/bash

set -x
apk update

rm -rf /var/cache/apk/*
rm -f /build.sh || true
