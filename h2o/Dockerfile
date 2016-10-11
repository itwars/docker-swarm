FROM alpine:3.4
RUN echo http://mirrors.2f30.org/alpine/edge/community >> /etc/apk/repositories \
 && apk add --update --no-cache h2o \
 && rm -rf /var/cache/apk/* \
 && mkdir /etc/h2o \
 && ln -sf /dev/stdout /var/log/h2o/access.log \
 && ln -sf /dev/stderr /var/log/h2o/error.log

EXPOSE 8001
ADD h2o.conf /etc/h2o/
ADD ./www /var/www/html

CMD ["/usr/bin/h2o", "-c", "/etc/h2o/h2o.conf", "-m", "master"]
