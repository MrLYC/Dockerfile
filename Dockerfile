FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

VOLUME [ "/data" ]

EXPOSE 161/udp

ADD build.sh /build.sh
ADD entry.sh /entry.sh

ENV DOCKER_DEBUG 0
ENV COMMUNITY mrlyc
ENV LOG_LEVEL 0-3d
ENV LOG_FILE snmpd.log
ENV AGENT_ADDRESS udp:0.0.0.0:161
ENV CONFIG_SED_COMMAND ""

WORKDIR /

RUN ["/build.sh"]

ENTRYPOINT ["/entry.sh"]
