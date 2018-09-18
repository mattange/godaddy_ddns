FROM alpine:3.8

COPY entrypoint.sh /
RUN apk add -q --progress --update --no-cache curl bash ca-certificates && \
    rm -rf /var/cache/apk/* && \
    chmod +x /entrypoint.sh

ENV TARGETS= \
    KEY= \
    SECRET= \
    DELAY=3600 \
    TTL=1800

ENTRYPOINT /entrypoint.sh
    
