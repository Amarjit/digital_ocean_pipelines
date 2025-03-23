#!/bin/bash

echo -e "\n 🟩 Creating deployment script for $DOMAIN..."
# copy deploy.sh to /var/www/$DOMAIN/deploy/deploy.sh
cp deploy.sh /var/www/$DOMAIN/deploy/deploy.sh
chmod +x /var/www/$DOMAIN/deploy/deploy.sh
chown -R www-data:www-data /var/www/$DOMAIN/deploy/deploy.sh

echo -e "\n ✅  Deployment script created for $DOMAIN."
