#!/bin/bash

echo -e "\n 🟩 Setting up webhook recipient PHP script..."

echo -e "\n 🟩 Creating webhook log folder..."
mkdir -p /var/www/$DOMAIN/logs
chown -R www-data:www-data /var/www/$DOMAIN/logs
chmod -R 644 /var/www/$DOMAIN/logs

echo -e "\n 🟩 Creating blank webhook logfile..."
touch /var/www/$DOMAIN/logs/webhook.log
chown www-data:www-data /var/www/$DOMAIN/logs/webhook.log
chmod 644 /var/www/$DOMAIN/logs/webhook.log

echo -e "\n ✅  Copying webhook recipient PHP script to domain..."
cp setup/webhook/webhook.php /var/www/$DOMAIN/public_html/webhook.php
chown www-data:www-data /var/www/$DOMAIN/public_html/webhook.php
chmod 644 /var/www/$DOMAIN/public_html/webhook.php

echo -e "\n 🟩 Completed webook setup."
