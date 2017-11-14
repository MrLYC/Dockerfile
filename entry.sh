#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

cat << EOF > pyspider.json
{
    "webui": {
        "username": "${USERNAME}",
        "password": "${PASSWORD}",
        "need-auth": true
    }
}
EOF

pyspider -c pyspider.json
