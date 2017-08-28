#!/bin/sh

if [[ "${DOCKER_DEBUG}" == "1" ]]; then
    set -x
fi

work_dir="/hexo"

git config --global user.name "${GIT_USER}"
git config --global user.email "${GIT_EMAIL}"

if [ ! -e "${work_dir}" ]; then
    if [ "${GIT_ADDR}" != "" ]; then
        git clone --depth 1 ${GIT_ADDR} "${work_dir}"
    else
        mkdir -p "${work_dir}"
    fi
fi
cd "${work_dir}"

hexo "$@"
