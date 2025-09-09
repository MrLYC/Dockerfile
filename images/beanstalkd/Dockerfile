FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD build.sh /build.sh
ADD entry.sh /entry.sh

EXPOSE 11300

ENV DOCKER_DEBUG 0
ENV USER nobody
ENV ZBYTES 65535
ENV SBYTES 10485760
ENV OPTIONS ""

WORKDIR /
RUN ["/build.sh"]

ENTRYPOINT ["/entry.sh"]
