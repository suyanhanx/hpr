FROM icyleafcn/alpine:3.8

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY hpr /app/hpr
COPY deps/ /

WORKDIR /app

RUN apk update && apk add --no-cache openssh-keygen git bash openssl-dev

VOLUME ["/app/config", "/app/repositories"]

EXPOSE 8848/tcp

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["hpr:init"]
