FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD entry.sh /entry.sh
ENV DOCKER_DEBUG 0

RUN set -x && \
    apk update && \
    rm -rf /var/cache/apk/*

ENTRYPOINT ["/entry.sh"]
