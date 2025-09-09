#!/bin/sh

set -x
apt-get update
apt-get install -y curl wget python-dev python-pip

mkdir -p /root/.ssh

bash -c "$(curl -sSL https://raw.githubusercontent.com/jamesrwhite/minicron/master/install.sh)"

