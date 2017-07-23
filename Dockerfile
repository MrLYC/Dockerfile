FROM tomcat:9-jre8-alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD entry.sh /entry.sh
ADD build.sh /build.sh

ENV JAVA_OPTS "-Xmx512m -Xms128m"

ENV DOCKER_DEBUG 0
ENV INDEXING_DELAY 1

ENV GIT_SOURCE ""
ENV TAR_SOURCE ""
ENV TGZ_SOURCE ""
ENV ZIP_SOURCE ""

EXPOSE 8080
VOLUME /var/opengrok
VOLUME /var/opengrok/src

WORKDIR /

RUN ["/build.sh"]

ENTRYPOINT ["/entry.sh"]
