FROM alpine:3.19
RUN apk add --no-cache curl
COPY bin/marker /usr/local/bin/marker
COPY src/marker/content /opt/marker/content
COPY src/marker/templates /opt/marker/templates
COPY src/marker/static /opt/marker/static
EXPOSE 8080
CMD [/usr/local/bin/marker --content /opt/marker/content --templates /opt/marker/templates --static /opt/marker/static]
