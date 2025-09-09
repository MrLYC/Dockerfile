FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD entry.sh /entry.sh

ENV DOCKER_DEBUG 0
ENV LOCALADDR :12948
ENV REMOTEADDR 127.0.0.1:29900
ENV KEY "it's a secrect"
ENV CRYPT aes
ENV MODE fast
ENV CONN 1
ENV AUTOEXPIRE 0
ENV MTU 1350
ENV SNDWND 128
ENV RCVWND 1024
ENV DATASHARD 10
ENV PARITYSHARD 3
ENV DSCP 0

WORKDIR /

RUN set -x && \
    apk update && \
    apk add --no-cache go git && \
    env GOPATH=/ go get github.com/xtaci/kcptun/client && \
    apk del go git && \
    rm -rf /var/cache/apk/*

EXPOSE 12948

ENTRYPOINT ["/entry.sh"]
