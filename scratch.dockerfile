FROM    scratch

LABEL   maintainer="support+docker@vairogs.com"
LABEL   org.opencontainers.image.source="https://github.com/960018/docker"
LABEL   org.opencontainers.image.description="custom built image with same user (vairogs) throughout all images"
LABEL   org.opencontainers.image.licenses="MIT"

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

USER    vairogs

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]
