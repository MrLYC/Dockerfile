#!/bin/sh

if [ "${DOCKER_DEBUG}" == "1" ]; then
    set -x
fi

USER_NAME=${USER_NAME:-sharing}
WEBDAV_SHARE=${WEBDAV_SHARE:-/data}
if [ "${USER_PASSWD}" == "" ]; then
    USER_PASSWD=${RANDOM}
    echo "random password:" ${USER_PASSWD}
fi

sed -i -e "/^${USER_NAME}:webdav:/d" /etc/apache2/htpasswd
echo "${USER_NAME}:webdav:$(echo -n "${USER_NAME}:webdav:${USER_PASSWD}" | md5sum | cut -d ' ' -f 1)" >> /etc/apache2/htpasswd

if [ "${1/f/F}" = "-F" -o ! -s /etc/apache2/httpd.conf -o \( ! -z "${WEBDAV_SHARE}" -a "$(df /etc/apache2/httpd.conf)" = "$(df /)" \) ]; then
	cat /usr/local/etc/httpd.conf > /tmp/httpd.conf
	sed -i -e "s@/data@${WEBDAV_SHARE}@g" /tmp/httpd.conf
	cat /tmp/httpd.conf > /etc/apache2/httpd.conf
	rm -rf /tmp/httpd.conf

	mkdir -p ${WEBDAV_SHARE}
fi

exec httpd -D FOREGROUND

