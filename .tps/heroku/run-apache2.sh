#!/usr/bin/env bash

# https://github.com/docker-library/wordpress/issues/293#issuecomment-557860238

# TODO:
# 2021-06-10T06:21:44.158138+00:00 app[web.1]: AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.17.190.254. Set the 'ServerName' directive globally to suppress this message

echo "PORT: ${PORT}"

sed -i "s/Listen 80/Listen ${PORT:-80}/g" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:${PORT:-80}>/g" /etc/apache2/sites-available/000-default.conf

apache2-foreground "$@"
