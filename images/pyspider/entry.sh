#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

cat << EOF > pyspider.json
{
    "taskdb": "${TASKDB}",
    "projectdb": "${PROJECTDB}",
    "resultdb": "${RESULTDB}",
    "message_queue": "${MESSAGEQ}",
    "webui": {
        "username": "${USERNAME}",
        "password": "${PASSWORD}",
        "need-auth": ${NEEDAUTH}
    }
}
EOF

pyspider "$@"
