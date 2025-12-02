#!/bin/bash
set -euo pipefail

TEMPLATE=/local/tmp/vhost.template
OUTDIR=/etc/apache2/sites-available
APACHE_LOG_DIR="${APACHE_LOG_DIR:-/var/log/apache2}"
mkdir -p "$APACHE_LOG_DIR"

INPUT="$1"
echo "[create-vhosts] VHOSTS='$INPUT'"

a2dissite 000-default.conf >/dev/null 2>&1 || true

IFS=';' read -ra ITEMS <<< "${INPUT}"
for item in "${ITEMS[@]}"; do
    [ -z "$item" ] && continue
    IFS=':' read -r ENVNAME PORT DOCROOT <<< "$item"
    if [ -z "${DOCROOT-}" ]; then
        DOCROOT="/local/www/${ENVNAME}"
    fi
    ENVNAME_UP=$(echo "$ENVNAME" | tr '[:lower:]' '[:upper:]')
    export ENVNAME ENVNAME_UP PORT DOCROOT APACHE_LOG_DIR
    dest="${OUTDIR}/${ENVNAME}.conf"
    envsubst '${ENVNAME} ${ENVNAME_UP} ${PORT} ${DOCROOT} ${APACHE_LOG_DIR}' \
        < "${TEMPLATE}" > "${dest}"
    a2ensite "$(basename "${dest}")"
done
