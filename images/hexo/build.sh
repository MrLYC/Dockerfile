#!/bin/sh

set -x
apk update

apk add git openssh sudo
sudo npm install hexo-cli -g

npm install
npm install hexo-generator-sitemap --save
npm install hexo-generator-feed --save
npm install hexo-deployer-git --save

rm -rf /var/cache/apk/*
rm -f /build.sh || true
