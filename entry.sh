#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

ssh-keygen -A

if [[ "${AUTHORIZED_KEYS}" != "" ]]; then
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    echo "${AUTHORIZED_KEYS}" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi
if [[ "${AUTH_PASSWORD}" != "" ]]; then
    sed -i s/#*PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config
    sed -i s/#*PasswordAuthentication.*/PasswordAuthentication\ yes/ /etc/ssh/sshd_config
    echo "root:${AUTH_PASSWORD}" | chpasswd
fi

exec /usr/sbin/sshd -D
