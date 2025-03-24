#!/bin/bash

echo -e "\n 🟩 Setting up webhook recipient PHP script..."

echo -e "\n 🟩 Creating webhook log folder..."
mkdir -p /var/www/$DOMAIN/logs
chown -R www-data:www-data /var/www/$DOMAIN/logs
chmod -R 700 /var/www/$DOMAIN/logs

echo -e "\n 🟩 Creating blank webhook logfile..."
touch /var/www/$DOMAIN/logs/webhook.log
chown www-data:www-data /var/www/$DOMAIN/logs/webhook.log
chmod 700 /var/www/$DOMAIN/logs/webhook.log

echo -e "\n 🟩  Copying webhook recipient PHP script to domain..."
cp setup/webhook/webhook.php /var/www/$DOMAIN/public/webhook.php
chown www-data:www-data /var/www/$DOMAIN/public/webhook.php
chmod 600 /var/www/$DOMAIN/public/webhook.php
chmod +x /var/www/$DOMAIN/public/webhook.php

echo -e "\n 🟩  Replacing GitHub webhook secret key in webhook.php..."
sed -i "s/SECRET_EXAMPLE/$GIT_WEBHOOK_SECRET/g" /var/www/$DOMAIN/public/webhook.php

echo -e "\n ✅ Completed webook setup."
