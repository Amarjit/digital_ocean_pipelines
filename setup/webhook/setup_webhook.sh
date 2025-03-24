#!/bin/bash

echo -e "\n 🟩  Setting up webhook recipient PHP script..."

echo -e "\n 🟩  Creating webhook log folder..."
mkdir -p /var/www/$DOMAIN/logs
chown -R www-data:www-data /var/www/$DOMAIN/logs
chmod -R 100 /var/www/$DOMAIN/logs # execute-only

echo -e "\n 🟩  Creating blank webhook logfile..."
touch /var/www/$DOMAIN/logs/webhook.log
chown www-data:www-data /var/www/$DOMAIN/logs/webhook.log
chmod 200 /var/www/$DOMAIN/logs/webhook.log # write-only

# Create webhook inside artifact folder so that it can be copied over for every fresh deployment.
echo -e "\n 🟩  Creating webhook artifact for use in deployment..."
cp setup/webhook/webhook.php /var/www/$DOMAIN/deploy/artifacts/webhook.php
chown www-data:www-data /var/www/$DOMAIN/deploy/artifacts/webhook.php
chmod 400 /var/www/$DOMAIN/deploy/artifacts/webhook.php # read-only

echo -e "\n 🟩  Copying webhook recipient PHP script to domain to allow for immediate website cloning..."
cp setup/webhook/webhook.php /var/www/$DOMAIN/public/webhook.php
chown www-data:www-data /var/www/$DOMAIN/public/webhook.php
chmod 400 /var/www/$DOMAIN/public/webhook.php # read-only
chmod +x /var/www/$DOMAIN/public/webhook.php

echo -e "\n 🟩  Replacing GitHub webhook secret key in webhook.php..."
sed -i "s/SECRET_EXAMPLE/$GIT_WEBHOOK_SECRET/g" /var/www/$DOMAIN/public/webhook.php

echo -e "\n ✅  Completed webook setup."
