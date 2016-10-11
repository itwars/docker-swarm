FROM alpine:3.4
RUN apk --update --no-cache add varnish \
 && rm -rf /var/cache/apk/* 
ADD default.vcl /etc/varnish/
EXPOSE 8000
CMD exec varnishd -F \
  -a :8000 \
  -f /etc/varnish/default.vcl \
  -s malloc,100M
