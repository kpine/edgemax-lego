#!/bin/sh

export LEGO_HOME=/config/scripts/lego
export LEGO_PATH="$LEGO_HOME/data"

if [ ! -f "$LEGO_HOME/lego.cfg" ]; then
  echo "DNS provider settings are missing"
  exit 1
fi

. "$LEGO_HOME/lego.cfg"

if [ -z "$LETSENCRYPT_EMAIL" ] || [ -z "$DOMAINS" ] || [ -z "$DNS_PROVIDER" ]; then
  echo "A required enviroment variable is missing (LETSENCRYPT_EMAIL, DOMAINS, DNS_PROVIDER)"
  exit 1
fi

echo "Renewing certificate"
"$LEGO_HOME/lego" --accept-tos --email "$LETSENCRYPT_EMAIL" --domains "$DOMAINS" --dns "$DNS_PROVIDER" renew --renew-hook "$LEGO_HOME/deploy.sh"