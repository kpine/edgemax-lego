#!/bin/sh

LEGO_HOME=/config/scripts/lego

[ -f "$LEGO_HOME/lego.cfg" ] && . "$LEGO_HOME/lego.cfg"

if [ -z "$LETSENCRYPT_EMAIL" ] || [ -z "$DOMAINS" ] || [ -z "$DNS_PROVIDER" ]; then
  echo "A required enviroment variable is missing (LETSENCRYPT_EMAIL, DOMAINS, DNS_PROVIDER)"
  exit 1
fi

action="renew"
[ "$1" = "run" ] && action="run"

server=
[ -n "$USE_STAGING" ] && server="https://acme-staging-v02.api.letsencrypt.org/directory"

echo "Generating certificate"\
"$LEGO_HOME/lego"
  ${server:+ --server="$server"} \
  --path "${LEGO_HOME}/data" \
  --accept-tos \
  --email "${LETSENCRYPT_EMAIL}" \
  --domains "${DOMAINS}" \
  --dns "${DNS_PROVIDER}" \
  "${action}" \
  "--${action}-hook" "${LEGO_HOME}/deploy.sh"