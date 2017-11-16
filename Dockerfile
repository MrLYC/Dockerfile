FROM debian:stretch

MAINTAINER lyc <imyikong@gmail.com>

ADD build.sh /build.sh
ADD entry.sh /entry.sh
ENV DOCKER_DEBUG 0

ENV NEEDAUTH true
ENV USERNAME mrlyc
ENV PASSWORD pass
ENV TASKDB sqlite+taskdb:///opt/spider/task.db
ENV PROJECTDB sqlite+taskdb:///opt/spider/project.db
ENV RESULTDB sqlite+taskdb:///opt/spider/result.db
ENV MESSAGEQ ""

ENV LANG C.UTF-8
ENV LANG C.UTF-8

EXPOSE 5000

WORKDIR ["/opt/pyspider"]
RUN ["/build.sh"]

VOLUME ["/opt/pyspider"]

ENTRYPOINT ["/entry.sh"]
