FROM    ghcr.io/960018/debian:latest AS builder

ARG     CACHE_BUSTER=default

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

COPY    --chmod=0755 cron/update_crontab.sh /usr/local/bin/update_crontab
COPY    --chmod=0755 cron/entrypoint.sh /usr/local/bin/entrypoint
COPY    --from=docker:28-dind-rootless --chmod=0755 /usr/local/bin/docker /usr/local/bin/docker
COPY    --from=docker:28-dind-rootless --chmod=0755 /usr/local/libexec/docker/cli-plugins/docker-buildx /usr/local/libexec/docker/cli-plugins/docker-buildx
COPY    --from=docker:28-dind-rootless --chmod=0755 /usr/local/libexec/docker/cli-plugins/docker-compose /usr/local/libexec/docker/cli-plugins/docker-compose

VOLUME  ["/var/run/docker.sock"]

WORKDIR /home/vairogs

USER    root

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      ln -sf /usr/bin/vi /usr/bin/vim \
&&      chown vairogs:vairogs /usr/local/bin/update_crontab \
&&      chown vairogs:vairogs /usr/local/bin/entrypoint \
&&      mkdir --parents /cron/scripts \
&&      mkdir --parents /var/spool/cron/crontabs \
&&      mkdir --parents /var/run/crond \
&&      chown -R vairogs:vairogs /cron \
&&      chown -R vairogs:vairogs /var/spool/cron/crontabs \
&&      chown -R vairogs:vairogs /var/run/crond \
&&      rm -rf \
            ~/.pearrc \
            /home/vairogs/*.deb \
            /home/vairogs/*.gz \
            /*.deb \
            /tmp/* \
            /var/cache/* \
            /usr/share/vim/vim90/doc \
            /usr/share/man/*

RUN     \
        set -eux; \
        if [ ! -S /var/run/docker.sock ]; then \
            mkdir -p /var/run && \
            touch /var/run/docker.sock && \
            chmod 000 /var/run/docker.sock; \
        fi

WORKDIR /cron

CMD     ["cron", "-f"]

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

WORKDIR /cron

USER    root

RUN     mkdir -p /var/run/crond && chown -R vairogs:vairogs /var/run/crond

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD     ["cron", "-f"]
