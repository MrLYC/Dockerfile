FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD entry.sh /entry.sh

RUN apk update && \
    apk add py-pip && \
    pip install yapf && \
    apk del py-pip && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/entry.sh"]
