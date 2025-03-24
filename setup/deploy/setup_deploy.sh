#!/bin/bash

echo -e "\n 🟩 Creating deployment script for $DOMAIN..."

# Create deployment directory.
echo -e "\n 🟩 Creating deployment directory..."
mkdir -p /var/www/$DOMAIN/deploy
chmod -R 100 /var/www/$DOMAIN/deploy # execute-only
chown -R www-data:www-data /var/www/$DOMAIN/deploy


echo -e "\n 🟩 Creating deployment script..."
cp setup/deploy/deploy.sh /var/www/$DOMAIN/deploy/deploy.sh
chmod 500 /var/www/$DOMAIN/deploy/deploy.sh # read and execute
chown -R www-data:www-data /var/www/$DOMAIN/deploy/deploy.sh

echo -e "\n ✅  Deployment script created for $DOMAIN."
