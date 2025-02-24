FROM    scratch

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

USER    vairogs

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]

ENTRYPOINT ["/home/vairogs/env_entrypoint.sh"]
