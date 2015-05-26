FROM debian:jessie

RUN echo "export SHELL=/bin/bash" >> /root/.bashrc
ENV DEBIAN_FRONTEND noninteractive

RUN \
   apt-get update && \
   apt-get install -y \
      sudo \
      git \
      curl \
      python \
      cmake \
      make \
      pkg-config \
      strace \
      valgrind \
      libc-dbg \
      openssl \
      libssl-dev && \
   apt-get clean autoclean && apt-get autoremove -y && \
   rm -rf /var/lib/apt /var/lib/cache/* /var/lib/log/*

ADD https://get.docker.com/builds/Linux/x86_64/docker-latest /usr/bin/docker
RUN chmod +x /usr/bin/docker

ENV RUST_VERSION=nightly

RUN \
   curl -sO https://static.rust-lang.org/dist/rust-$RUST_VERSION-x86_64-unknown-linux-gnu.tar.gz && \
   tar -xvzf rust-$RUST_VERSION-x86_64-unknown-linux-gnu.tar.gz && \
   ./rust-$RUST_VERSION-x86_64-unknown-linux-gnu/install.sh && \
   rm -rf /rust-$RUST_VERSION-x86_64-unknown-linux-gnu{,.tar.gz} && \
   rm -rf /usr/local/share/doc/rust

VOLUME ["/rust"]
ENV USER root

WORKDIR /rust
ENTRYPOINT ["/bin/bash"]
