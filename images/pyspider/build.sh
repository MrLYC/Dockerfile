#!/bin/sh

set -x

echo "deb http://ftp.de.debian.org/debian testing main" >> /etc/apt/sources.list
echo 'APT::Default-Release "stable";' | tee -a /etc/apt/apt.conf.d/00local

apt-get update

apt-get install -y --no-install-recommends \
    build-essential \
    chrpath \
    libssl-dev \
    libxft-dev \
    libfreetype6 \
    libfreetype6-dev \
    libfontconfig1 \
    libfontconfig1-dev 
    
apt-get install -y wget curl python3.6-dev

export PHANTOM_JS="phantomjs-1.9.8-linux-x86_64"
wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2
tar xvjf $PHANTOM_JS.tar.bz2
mv $PHANTOM_JS /usr/local/share
ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin
rm $PHANTOM_JS.tar.bz2
phantomjs --version

ln -sf /usr/bin/python3.6 /usr/bin/python
curl https://bootstrap.pypa.io/get-pip.py | python

apt-get install -y libcurl4-openssl-dev

export PYCURL_SSL_LIBRARY=openssl
pip install pyspider

mkdir -p /opt/pyspider

rm -rf /root/.cache/pip || true
rm -rf /var/lib/apt/lists/* || true
apt-get clean
