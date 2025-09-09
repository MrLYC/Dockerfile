.PHONY: apt-update
apt-update:
	apt-get update

.PHONY: recommend
recommend: apt-update
	apt-get install -y \
		telnet \
		python-dev \
		python-setuptools \
		python-pip \
		;

.PHONY: golang
golang:
	apt-get install -y golang

.PHONY: httpserver
httpserver:
	$(eval addr ?= 8080)
	python -m SimpleHTTPServer "${addr}"
