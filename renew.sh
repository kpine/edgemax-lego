#!/bin/sh

LEGO_HOME=/config/scripts/lego

if [ ! -f "$LEGO_HOME/lego.cfg" ]; then
  echo "Settings file does not exist."
  exit 1
fi

. "$LEGO_HOME/lego.cfg"

if [ -z "$LETSENCRYPT_EMAIL" ] || [ -z "$DOMAINS" ] || [ -z "$DNS_PROVIDER" ]; then
  echo "A required enviroment variable is missing (LETSENCRYPT_EMAIL, DOMAINS, DNS_PROVIDER)"
  exit 1
fi

[ "$1" = "run" ] && action="run" || action="renew"

echo "Generating certificate"
"$LEGO_HOME/lego" \
  --path "${LEGO_HOME}/data" \
  --accept-tos \
  --email "${LETSENCRYPT_EMAIL}" \
  --domains "${DOMAINS}" \
  --dns "${DNS_PROVIDER}" \
  "${action}" \
  "--${action}-hook" "${LEGO_HOME}/deploy.sh"