ARG     VERSION=17
ARG     POSTGRES_IMAGE=postgres:${VERSION}-bookworm
FROM    ${POSTGRES_IMAGE}

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

COPY    global/01_nodoc   /etc/dpkg/dpkg.cfg.d/01_nodoc
COPY    global/02_nocache /etc/apt/apt.conf.d/02_nocache
COPY    global/compress   /etc/initramfs-tools/conf.d/compress
COPY    global/modules    /etc/initramfs-tools/conf.d/modules
COPY    global/90parallel /etc/apt/apt.conf.d/90parallel

ARG     POSTGRES_LOCALE=C.UTF-8

USER    root
RUN     chown -R postgres:postgres /var/lib/postgresql/

USER    postgres

ENV     POSTGRES_INITDB_ARGS="--lc-collate=${POSTGRES_LOCALE} --lc-ctype=${POSTGRES_LOCALE}"

USER    root

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends postgresql-contrib \
&&      mkdir -p /backup \
&&      chown -R postgres:postgres /backup \
&&      mkdir -p /docker-entrypoint-initdb.d \
&&      mkdir -p /backup/scripts \
&&      mkdir -p /backup/dumps \
&&      apt-get autoremove -y --purge \
&&      rm -rf \
            /home/vairogs/*.deb \
            /*.deb \
            /tmp/* \
            /usr/share/man \
            /usr/share/doc \
            /usr/local/share/man \
            /var/lib/apt/lists/* \
            /usr/lib/python3.11/__pycache__ \
            /root/.cache

COPY    --chmod=0755 postgres/pg_backup.config /backup/scripts/pg_backup.config
COPY    --chmod=0755 postgres/pg_backup_rotated.sh /backup/scripts/pg_backup_rotated.sh
COPY    --chmod=0755 postgres/init.sh /docker-entrypoint-initdb.d/init.sh
COPY    --chmod=0755 postgres/custom_entrypoint.sh /usr/local/bin/custom_entrypoint.sh
COPY    --chmod=0755 postgres/install_extensions.sql /install_extensions.sql

ENTRYPOINT ["/usr/local/bin/custom_entrypoint.sh"]
