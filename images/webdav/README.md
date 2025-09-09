# [alpine-x64-apache2-webdav](https://hub.docker.com/r/forumi0721/alpine-x64-apache2-webdav/)
[![](https://images.microbadger.com/badges/version/forumi0721/alpine-x64-apache2-webdav.svg)](https://microbadger.com/images/forumi0721/alpine-x64-apache2-webdav "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/forumi0721/alpine-x64-apache2-webdav.svg)](https://microbadger.com/images/forumi0721/alpine-x64-apache2-webdav "Get your own image badge on microbadger.com") [![Docker Stars](https://img.shields.io/docker/stars/forumi0721/alpine-x64-apache2-webdav.svg?style=flat-square)](https://hub.docker.com/r/forumi0721/alpine-x64-apache2-webdav/) [![Docker Pulls](https://img.shields.io/docker/pulls/forumi0721/alpine-x64-apache2-webdav.svg?style=flat-square)](https://hub.docker.com/r/forumi0721/alpine-x64-apache2-webdav/)



----------------------------------------
#### Description
* Distribution : [Alpine Linux](https://alpinelinux.org/)
* Architecture : x64
* Base Image   : [forumi0721/alpine-x64-base](https://hub.docker.com/r/forumi0721/alpine-x64-base/)
* Appplication : [Apache2](https://httpd.apache.org/)
    - The Apache HTTP Server Project is an effort to develop and maintain an open-source HTTP server for modern operating systems including UNIX and Windows.
    - WebDAV



----------------------------------------
#### Run
```sh
docker run -d \
        -p 80:80/tcp \
        -v /data:/data \
        -e USER_NAME=username \
        -e USER_PASSWD=passwd \
        -e WEBDAV_SHARE=/data \
        forumi0721/alpine-x64-apache2-webdav:latest
```



----------------------------------------
#### Usage
* URL : [http://localhost:80/](http://localhost:80/)
    - Default username/password : forumi0721/passwd


###### Notes
* If you want to use multiple user, you need to create `htpasswd` and add `-v htpasswd:/etc/apache2/htpasswd` to docker option.



----------------------------------------
#### Docker Options
| Option             | Description                                      |
|--------------------|--------------------------------------------------|
| -                  | -                                                |


#### Environment Variables
| ENV                | Description                                      |
|--------------------|--------------------------------------------------|
| USER_NAME          | Login username (default : sharing)               |
| USER_PASSWD        | Login password                                   |
| USER_EPASSWD       | Login password (base64)                          |
| WEBDAV_SHARE       | WebDAV root directory (default : /data)          |


#### Volumes
| Volume             | Description                                      |
|--------------------|--------------------------------------------------|
| /data              | WebDav root directory                            |


#### Ports
| Port               | Description                                      |
|--------------------|--------------------------------------------------|
| 80/tcp             | HTTP port                                        |



----------------------------------------
* [forumi0721/alpine-x64-apache2-webdav](https://hub.docker.com/r/forumi0721/alpine-x64-apache2-webdav/)
* [forumi0721/alpine-armv7h-apache2-webdav](https://hub.docker.com/r/forumi0721/alpine-armv7h-apache2-webdav/)

