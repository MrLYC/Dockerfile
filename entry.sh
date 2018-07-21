#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

/opt/conda/bin/python /opt/conda/bin/jupyter-notebook --pylab "enabled" --notebook-dir /home/jovyan/work
