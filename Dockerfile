FROM jupyter/datascience-notebook

MAINTAINER lyc <imyikong@gmail.com>

ADD build.sh /build.sh
ADD entry.sh /entry.sh
ENV DOCKER_DEBUG 0

EXPOSE 8888

ENV TOKEN=mrlyc/jupyter

VOLUME [ "/home/jovyan/work", "/home/jovyan/" ]

WORKDIR /
RUN ["/build.sh"]

ENTRYPOINT ["/entry.sh"]
