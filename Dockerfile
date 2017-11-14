FROM python:3-alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD build.sh /build.sh
ADD entry.sh /entry.sh
ENV DOCKER_DEBUG 0
ENV USERNAME mrlyc
ENV PASSWORD pass

EXPOSE 5000

WORKDIR /
RUN ["/build.sh"]

ENTRYPOINT ["/entry.sh"]
