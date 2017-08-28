FROM node:6-alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD build.sh /build.sh
ADD entry.sh /entry.sh
ENV DOCKER_DEBUG 0

ENV GIT_USER "MrLYC"
ENV GIT_EMAIL "imyikong@gmail.com"

WORKDIR ["/"]
VOLUME ["/hexo"]

EXPOSE 4000

RUN ["/build.sh"]

ENTRYPOINT ["/entry.sh"]
CMD ["server"]
