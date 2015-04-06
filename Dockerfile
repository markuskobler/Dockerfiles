FROM gliderlabs/alpine:edge

ENV LOCAL  C.UTF-8

RUN \
  apk upgrade --update && \
  apk add postgresql postgresql-contrib && \
  rm -rf /var/cache/apk/* && \
  mkdir -p /var/lib/postgresql && \
  chown postgres:postgres /var/lib/postgresql

ADD ./initdb.sh /initdb.sh
ADD ./initdb.d  /initdb.d

ENV PGDATA /data

VOLUME ["/data"]

EXPOSE 5432

USER postgres

CMD ["/usr/bin/psql"]

# Init server with:
# docker run -it --name postgres-data --user root markuskobler/postgres /initdb.sh

# Run server with:
# docker run -d --volumes-from postgres-data -v /tmp -p 5432:5432 --name postgres markuskobler/postgres postgres

# Run psql client with:
# docker run --rm -it --volumes-from postgres markuskobler/postgres psql
