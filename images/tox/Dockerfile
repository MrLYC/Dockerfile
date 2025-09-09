FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD entry.sh /entry.sh

RUN apk update && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/entry.sh"]
