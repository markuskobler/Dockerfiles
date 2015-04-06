#!/bin/sh
set -e

if [ "$(id -u)" != "0" ]; then
   echo "initdb.sh must be run as root" 1>&2
   exit 1
fi

mkdir -p $PGDATA
chown -R postgres:postgres $PGDATA
su postgres -c "/usr/bin/initdb --auth-local=peer --auth-host=md5 --encoding=UTF-8 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8"

# think about enabling --data-checksums

sed -ri "s/^#(listen_addresses\s*=\s*)\S+/\1'*'\t/" "$PGDATA"/postgresql.conf
cat <<EOF >> "$PGDATA"/pg_hba.conf
host    all             all             0.0.0.0/0               md5
host    all             all             ::/0                    md5
EOF
# TODO enable replication?

# TODO make optional
if [ true ]; then
    apk-install openssl

    sed -ri "s/^#(ssl\s*=\s*)\S+/\1on/" "$PGDATA"/postgresql.conf
    cat <<-EOF >> "$PGDATA"/pg_hba.conf
hostssl all             all             0.0.0.0/0               md5
hostssl all             all             ::/0                    md5
EOF

    export PASSPHRASE=$(head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c 128; echo)
    SUBJ="/C=/ST=/O=/localityName=/commonName=localhost/organizationalUnitName=/emailAddress=/"
    openssl req -new -text -out "$PGDATA"/server.req -subj "$SUBJ" -passout env:PASSPHRASE
    openssl rsa -in privkey.pem -passin env:PASSPHRASE -out "$PGDATA"/server.key
    openssl req -x509 -in "$PGDATA"/server.req -text -key "$PGDATA"/server.key -out "$PGDATA"/server.crt
    chown postgres:postgres "$PGDATA"/server.key "$PGDATA"/server.crt
    chmod 0600 "$PGDATA"/server.key
    rm privkey.pem "$PGDATA"/server.req

    apk del openssl
fi

if [ -d /initdb.d ]; then
    for f in /initdb.d/*.sh; do
	[ -f "$f" ] && . "$f"
    done
fi
