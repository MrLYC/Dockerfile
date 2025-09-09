#!/bin/sh

if [ "${DOCKER_DEBUG}" == "1" ]; then
    set -x
fi


setup_auth () {
    if [ "${AUTHORIZED_KEYS}" != "" ]; then
        echo "=> Found authorized keys"
        mkdir -p /root/.ssh
        chmod 700 /root/.ssh
        echo "" > /root/.ssh/authorized_keys
        chmod 600 /root/.ssh/authorized_keys
        IFS=$'\n'
        arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
        for x in $arr
        do
            x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
            cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
                echo "$x" >> /root/.ssh/authorized_keys
            fi
        done
    fi

    if [ ! -f /.root_pw_set ]; then
        /set_root_pw.sh
    fi
}

init_env() {
    if [ "${INITSH}" != "" ]; then
        cd /root/init
        for i in $(echo "${INITSH}" | tr ";" "\n"); do
            filename=./init${counter}.sh
            counter=$((${counter}+1))
            wget "${i}" -O ${filename}
            chmod +x ${filename}
            ${filename}
        done
    fi
}

setup_auth
init_env

cat > /etc/minicron.toml << EOF
verbose = ${VERBOSE:-false}
debug = ${DEBUG:-true}

[client]
    [client.server]
        scheme = "${APT_SCHEMA:-http}"
        host = "${CLIENT_SERVER_API_HOST:-${SERVER_API_HOST}}"
        port = ${PORT:-8080}
        path = "${API_PATH:-/}"
        connect_timeout = ${CLIENT_SERVER_CONNECT_TIMEOUT:-5}
        inactivity_timeout = ${CLIENT_SERVER_INACTIVITY_TIMEOUT:-5}
    [client.cli]
        mode = "${CLIENT_CLI_MODE:-line}"
        dry_run = ${CLIENT_CLI_DRY_RUN:-false}

[server]
    host = "${SERVER_API_HOST:-0.0.0.0}"
    port = ${PORT:-8080}
    path = "${APIPATH:-/}"
    pid_file = "${SERVER_PID_FILE:-/tmp/minicron.pid}"

    [server.session]
        name = "${SERVER_SESSION_NAME:-minicron.session}"
        domain = "${SERVER_SESSION:-127.0.0.1}"
        path = "${SERVER_SESSION_PATH:-/}"
        ttl = ${SERVER_SESSION_TTL:-86400}
        secret = "${SERVER_SESSION_SECRET:-lyc}"

    [server.database]
        type = "${DB_TYPE:-sqlite}"
        host = "${DB_HOST:-127.0.0.1}"
        database = "${DB_NAME:-minicron}"
        username = "${DB_USER:-minicron}"
        password = "${DB_PASSWORD:-minicron}"

    [server.ssh]
        connect_timeout = ${SERVER_SSH_CONNECT_TIMEOUT:-10}

[alerts]
    [alerts.email]
        enabled =  ${ALERTS_EMAIL_ENABLE:-false}
        from = "${ALERTS_EMAIL_FROM:-from@example.com}"
        to = "${ALERTS_EMAIL_TO:-to@example.com}"
        [alerts.email.smtp]
            address = "${ALERTS_EMAIL_SMTP_ADDRESS:-localhost}"
            port = ${ALERTS_EMAIL_SMTP_PORT:-25}
            domain = "${ALERTS_EMAIL_SMTP_DOMAIN:-your.domain.name}"
            user_name = "${ALERTS_EMAIL_SMTP_USER_NAME:-username@email.com}"
            password = "${ALERTS_EMAIL_SMTP_PASSWORD:-password}"
            authentication = "${ALERTS_EMAIL_SMTP_AUTHENTICATION:-plain}"
            enable_starttls_auto = ${ALERTS_EMAIL_SMTP_ENABLE_STARTTLS_AUTO:-true}
EOF

if [ "${MINICRON_DB_SETUP:-0}" = "1" ]; then
    minicron db setup
fi

service ssh start
minicron server start
