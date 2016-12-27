FROM alpine

MAINTAINER lyc <imyikong@gmail.com>

ADD minio /
ADD entry.sh /
ADD build.sh /

ENV BUCKET_ROOT /export
ENV CONFIG_DIR /export/system
ENV ACCESS_KEY minio
ENV SECRET_KEY minio_demo
ENV REGION us-east-1

WORKDIR /
RUN ["/build.sh"]

EXPOSE 9000
VOLUME /export

ENTRYPOINT ["/entry.sh"]
