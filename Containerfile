FROM rust:1.75-alpine3.19 as builder
WORKDIR /usr/src/marker
RUN apk add --no-cache musl-dev
COPY . .
RUN cargo install --path .

FROM alpine:3.19
COPY --from=builder /usr/local/cargo/bin/marker /usr/local/bin/marker
COPY content /var/content
COPY templates /var/templates
EXPOSE 8080
WORKDIR /var
CMD [/usr/local/bin/marker /var/content]
