#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

/beanstalkd -u "${USER}" -z "${ZBYTES}" -s "${SBYTES}" ${OPTIONS}
