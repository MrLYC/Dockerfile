FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD build.sh /build.sh
ADD entry.sh /entry.sh
ENV DOCKER_DEBUG 0

WORKDIR /
RUN ["/build.sh"]

ENTRYPOINT ["/entry.sh"]
