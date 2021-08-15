#!/bin/sh

# check for required environment variables, these are set by Lego
if [ -z "$LEGO_CERT_DOMAIN" ] || [ -z "$LEGO_CERT_PATH" ] || [ -z "$LEGO_CERT_KEY_PATH" ]; then
    echo "Missing a required environment variable."
    exit 1
fi

echo "Deploying certificates."
mkdir -p /config/ssl
mv /config/ssl/server.pem /config/ssl/server.pem.bak
cat "$LEGO_CERT_KEY_PATH" "$LEGO_CERT_PATH" > /config/ssl/server.pem

echo "Restarting gui service."
killall lighttpd
/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
