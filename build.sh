#!/bin/sh

set -x

source /entry.sh info

apk update

apk add wget git ctags zip tar subversion make

wget https://github.com/OpenGrok/OpenGrok/releases/download/1.1-rc5/opengrok-1.1-rc5.tar.gz -O opengrok.tar.gz || exit 1
tar -xvf opengrok.tar.gz -C /usr/local || exit 2
mv /usr/local/opengrok* /usr/local/opengrok

init
tomcat_on

rm -rf /usr/local/tomcat/webapps/*

OpenGrok deploy

mv /usr/local/tomcat/webapps/source /usr/local/tomcat/webapps/ROOT

rm opengrok.tar.gz
rm -rf /var/cache/apk/*
