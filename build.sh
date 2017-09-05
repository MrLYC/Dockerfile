#!/bin/sh

set -x

source /entry.sh info

apk update

apk add wget git ctags zip tar subversion make

wget https://github.com/OpenGrok/OpenGrok/releases/download/1.1-rc5/opengrok-1.1-rc5.tar.gz -O opengrok.tar.gz || exit 1
tar -xvf opengrok.tar.gz -C /usr/local || exit 2
mv /usr/local/opengrok* /usr/local/opengrok

init

export OPENGROK_TOMCAT_BASE=${OPENGROK_TOMCAT_BASE:-/usr/local/tomcat}
tomcat_on

OpenGrok deploy

find ${OPENGROK_TOMCAT_BASE}/webapps/ -type d -mindepth 1 -maxdepth 1 ! -name source -exec rm -rf {} \;
mv ${OPENGROK_TOMCAT_BASE}/webapps/source.war ${OPENGROK_TOMCAT_BASE}/webapps/ROOT.war

rm opengrok.tar.gz
rm -rf /var/cache/apk/*
