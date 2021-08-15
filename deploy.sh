#!/bin/sh

echo "Deploying certificate for domain ${LEGO_CERT_DOMAIN}."
mkdir -p /config/ssl
cat "${LEGO_CERT_PATH}" "${LEGO_CERT_KEY_PATH}" > /config/ssl/server.pem

echo "Restarting webserver."
killall lighttpd
/usr/sbin/lighttpd -f /etc/lighttpd/lighttpd.conf
