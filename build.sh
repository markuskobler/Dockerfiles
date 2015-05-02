#!/usr/bin/env bash

set -eo pipefail

VERSION=1.5.11

cat <<EOF | docker build --pull -t "haproxy-build" -
FROM gliderlabs/alpine:edge

RUN apk add --update curl tar gcc make perl linux-headers libc-dev xz-dev zlib-dev pcre-dev

RUN \
  mkdir -p /openssl && \
  curl -sL https://www.openssl.org/source/openssl-1.0.2a.tar.gz | \
  tar xz -C /openssl --strip-components 1 && \
  cd /openssl && \
  ./config no-shared no-ssl2 no-ssl3 no-dso enable-ec_nistp_64_gcc_128 && \
  make depend && make

RUN \
  mkdir -p /haproxy && \
  curl -sL http://www.haproxy.org/download/1.5/src/haproxy-$VERSION.tar.gz | \
  tar xz -C /haproxy --strip-components 1 && \
  cd /haproxy && \
  make TARGET=linux2628 USE_OPENSSL=1 SSL_INC=/openssl/include SSL_LIB=/openssl USE_PCRE_JIT=1 USE_ZLIB=1 ADDLIB=-static CPU=native CPU_CFLAGS.native=-O3

EOF

ID=`docker inspect -f '{{ .Id }}' haproxy-build`

rm -rf out; mkdir -p out

docker save $ID | tar -xOf - "$ID/layer.tar" | tar -xf - -C out "haproxy/haproxy"
docker save $ID | tar -xOf - "$ID/layer.tar" | tar -xf - -C out "haproxy/haproxy-systemd-wrapper"

docker build -t markuskobler/haproxy:$VERSION .
docker tag -f markuskobler/haproxy:$VERSION quay.io/markus/haproxy:$VERSION
