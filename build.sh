#!/bin/sh

set -x
apk update
apk info > /tmp/info1.txt

apk add wget tar g++ make

cp /usr/include/fcntl.h /usr/include/sys/fcntl.h

wget https://github.com/kr/beanstalkd/archive/v1.10.tar.gz --no-check-certificate
tar -xvf v1.10.tar.gz
cd beanstalkd-1.10/
make
mv beanstalkd /beanstalkd

apk info > /tmp/info2.txt

rm -rf /var/cache/apk/*
rm -f /build.sh || true
grep -F -f /tmp/info1.txt /tmp/info2.txt | xargs -i apk del {} || true
rm -rf /tmp/*
