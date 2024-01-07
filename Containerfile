FROM alpine:3.19
COPY target/release/marker /opt/marker
COPY content /opt/content
EXPOSE 8080
WORKDIR /opt
ENTRYPOINT [marker content]
