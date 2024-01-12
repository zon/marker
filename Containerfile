FROM alpine:3.19
COPY target/release/marker /usr/local/bin/marker
COPY content /var/content
COPY templates /var/templates
EXPOSE 8080
CMD [/usr/local/bin/marker /var/content]
