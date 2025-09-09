FROM tutum/ubuntu:latest

MAINTAINER lyc <imyikong@gmail.com>

EXPOSE 80
EXPOSE 443
EXPOSE 22
EXPOSE 8080
EXPOSE 8081
EXPOSE 8082
EXPOSE 8083

ENV ROOT_PASS ""
ENV INITSH ""

RUN apt-get update && \
    apt-get install -y wget make && \
    mkdir -p /root/init/

WORKDIR /root/

ADD entry.sh /entry.sh
ADD Makefile /root/init/Makefile

ENTRYPOINT ["/entry.sh"]
