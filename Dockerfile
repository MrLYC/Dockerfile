FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD build.sh /build.sh
ADD entry.sh /entry.sh

ENV DOCKER_DEBUG 0

RUN ["/build.sh"]

EXPOSE 9000
WORKDIR /

ENTRYPOINT ["/entry.sh"]
