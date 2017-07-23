#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

export PATH=/usr/local/opengrok/bin:/usr/local/tomcat/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin:$PATH

export OPENGROK_TOMCAT_BASE=${OPENGROK_TOMCAT_BASE:-/usr/local/tomcat}
export CATALINA_PID=${CATALINA_PID:-/var/run/catalina.pid}

export OPENGROK_DIR="/var/opengrok"
export SOURCE_DIR="${OPENGROK_DIR}/src"

function init() {
    mkdir -p "${OPENGROK_DIR}/src"
    mkdir -p "${OPENGROK_DIR}/etc"
    mkdir -p "${OPENGROK_DIR}/data"
}

function tomcat_on() {
    if [[ -e "${CATALINA_PID}" ]]; then
        if kill -0 `cat ${CATALINA_PID}`; then
            return 0
        fi
    fi
	catalina.sh start
}

function opengrok_index() {
	OpenGrok index
}

function init_crontab() {
    crontab -l > cron.txt
    cat >> cron.txt << EOF
* * * * * /entry.sh tomcat_on
*/${INDEXING_DELAY:-1} * * * * /entry.sh opengrok_index
EOF
    crontab cron.txt
}

function info() {
    env
}

setup_git_source() {
    for i in $(echo "${GIT_SOURCE}" | tr ";" "\n"); do
        git clone --depth=1 "$i" "${SOURCE_DIR}"
        indexing_source
    done
}

setup_tar_source() {
    for i in $(echo "${TAR_SOURCE}" | tr ";" "\n"); do
        wget -O /tmp/source.tar $i
        tar -C "${SOURCE_DIR}" -xvf /tmp/source.tar
    done
    [ -e /tmp/source.tar ] && rm /tmp/source.tar
}

setup_tgz_source() {
    for i in $(echo "${TGZ_SOURCE}" | tr ";" "\n"); do
        wget -O /tmp/source.tar.gz $i
        tar -C "${SOURCE_DIR}" -xvf /tmp/source.tar.gz
    done
    [ -e /tmp/source.tar.gz ] && rm /tmp/source.tar.gz
}

setup_zip_source() {
    for i in $(echo "${ZIP_SOURCE}" | tr ";" "\n"); do
        wget -O /tmp/source.zip $i
        unzip -d "${SOURCE_DIR}" /tmp/source.zip
    done
    [ -e /tmp/source.zip ] && rm /tmp/source.zip
}

function start() {
    init
    init_crontab
    tomcat_on

    setup_tar_source &
    setup_tgz_source &
    setup_zip_source &

    opengrok_index
    crond -f
}

command_name="$1"
shift 1
if [[ "${command_name}" = "" ]]; then
    command_name='start'
fi
${command_name} $@
