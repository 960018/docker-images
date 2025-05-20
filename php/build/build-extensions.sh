#!/usr/bin/env bash

set -eux

if [[ ! -f /tmp/extensions.json ]]; then
   echo "Error: extensions.json not found. Terminating script."
   exit 1
fi

jobs="$(( $(nproc) / 2 ))"
[ "$jobs" -lt 1 ] && jobs=1

while IFS= read -r extension; do
    enable=$(jq -r '.["'"${extension}"'"].enable // "false"' extensions.json)
    source_dir=$(jq -r '.["'"${extension}"'"].source' extensions.json)

    if [[ "${enable}" == "true" ]]; then
        configure_flags=$(jq -r '.["'"${extension}"'"].configure' extensions.json)
        remove=$(jq -r '.["'"${extension}"'"].remove' extensions.json)
        req=$(jq -r '.["'"${extension}"'"].req' extensions.json)
        flags=$(jq -r '.["'"${extension}"'"].flags' extensions.json)

        if [[ -n "${req}" && "${req}" != "null" ]]; then
            apt-get install -y ${req}
        fi

        cd ${source_dir}
        phpize
        if [[ -n "${flags}" && "${flags}" != "null" ]]; then
            if [[ -n "${configure_flags}" && "${configure_flags}" != "null" ]]; then
                ./configure CFLAGS="${flags}" ${configure_flags}
            else
                ./configure CFLAGS="${flags}"
            fi
        else
            if [[ -n "${configure_flags}" && "${configure_flags}" != "null" ]]; then
                ./configure ${configure_flags}
            else
                ./configure
            fi
        fi
        make -j"${jobs}"
        make install

        docker-php-ext-enable ${extension}

        if (jq -e '.["'"${extension}"'"].scripts | type == "array"' /tmp/extensions.json); then
            temp_script=$(mktemp)

            while IFS= read -r script; do
                echo "${script}" >> "${temp_script}"
            done < <(jq -r '.["'"${extension}"'"].scripts[]' /tmp/extensions.json)

            chmod +x "${temp_script}"

            "${temp_script}"

            rm "${temp_script}"
        fi

        if [[ -n "${remove}" && "${remove}" != "null" ]]; then
            apt-get purge -y ${remove}
        fi

        cd -
    fi

    rm -rf ${source_dir}
done < <(jq -r 'keys[]' extensions.json)
