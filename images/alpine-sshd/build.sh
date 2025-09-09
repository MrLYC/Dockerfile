#!/bin/sh

set -x
apk update

apk add openssh sudo

sed -i s/#*PermitRootLogin.*/PermitRootLogin\ no/ /etc/ssh/sshd_config
sed -i s/#*PasswordAuthentication.*/PasswordAuthentication\ no/ /etc/ssh/sshd_config

rm -rf /var/cache/apk/*
