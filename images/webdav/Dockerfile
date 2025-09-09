FROM forumi0721/alpine-x64-base:latest

MAINTAINER lyc <imyikong@gmail.com>

ADD entry.sh /entry.sh
ADD build.sh /build.sh

ENV USER_NAME sharing
ENV USER_PASSWD ""
ENV WEBDAV_SHARE /data

RUN ["/build.sh"]

EXPOSE 80/tcp

VOLUME ["/data"]

ENTRYPOINT ["/entry.sh"]

