FROM alpine

ARG ARIANG_VERSION="latest"
ARG BUILD_DATE
ARG VCS_REF

ENV DOMAIN=0.0.0.0:90
ENV ARIA2RPCPORT=90
ENV ARIA2_USER=user
ENV ARIA2_PWD=pwd

LABEL maintainer="hurlenko" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.name="aria2-ariang" \
    org.label-schema.description="Aria2 downloader and AriaNg webui Docker image based on Alpine Linux" \
    org.label-schema.version=$ARIANG_VERSION \
    org.label-schema.url="https://github.com/hurlenko/aria2-ariang-docker" \
    org.label-schema.license="MIT" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/hurlenko/aria2-ariang-docker" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vendor="hurlenko" \
    org.label-schema.schema-version="1.0"

# use TUNA mirror source
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk update \
    && apk add --no-cache --update caddy aria2 su-exec

# AriaNG
WORKDIR /usr/local/www/ariang

RUN wget --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VERSION}/AriaNg-${ARIANG_VERSION}.zip \
    -O ariang.zip \
    && unzip ariang.zip \
    && rm ariang.zip \
    && chmod -R 755 ./

WORKDIR /aria2
# DHT data https://github.com/P3TERX/aria2.conf.git
COPY dht.dat ./cache/dht.data
COPY dht6.dat ./cache/dht6.dat

COPY aria2.conf ./conf-copy/aria2.conf
COPY start.sh ./
COPY Caddyfile /usr/local/caddy/

VOLUME /aria2/data
VOLUME /aria2/conf
VOLUME /aria2/cache

EXPOSE 90

ENTRYPOINT ["/bin/sh"]
CMD ["./start.sh"]
