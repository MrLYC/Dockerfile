FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD entry.sh /entry.sh
ADD build.sh /build.sh
ADD install.sql /install.sql

ENV DOCKER_DEBUG 0
ENV APPNAME webcron
ENV PORT 8080
ENV RUNMODE prod
ENV JOBS_POOL 10
ENV SITE_NAME WebCron

ENV DB_HOST 127.0.0.1
ENV DB_PORT 3306
ENV DB_USER root
ENV DB_PASSWORD password
ENV DB_NAME webcron
ENV DB_PREFIX cron_
ENV DB_TIMEZONE Asia/Shanghai

ENV MAIL_QSIZE 100
ENV MAIL_HOST smtp.example.com
ENV MAIL_PORT 25
ENV MAIL_FROM no-reply@example.com
ENV MAIL_USER username
ENV MAIL_PASSWORD password

EXPOSE 8080

WORKDIR /
RUN ["/build.sh"]

ENTRYPOINT ["/entry.sh"]
