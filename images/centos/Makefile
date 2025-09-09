.PHONY: yum-update
yum-update:
	yum update

.PHONY: recommend
recommend: yum-update
	yum install -y \
		telnet \
		python-dev \
		python-setuptools \
		python-pip \
		;

.PHONY: golang
golang:
	yum install -y golang

.PHONY: httpserver
httpserver:
	$(eval addr ?= 8080)
	python -m SimpleHTTPServer "${addr}"
