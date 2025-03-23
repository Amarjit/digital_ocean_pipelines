#!/bin/bash

echo -e "\n 🟩 Creating deployment script for $DOMAIN..."

# Create deployment directory.
echo -e "\n 🟩 Creating deployment directory..."
mkdir -p /var/www/$DOMAIN/deploy
chmod -R 700 /var/www/$DOMAIN/deploy
chown -R www-data:www-data /var/www/$DOMAIN/deploy


echo -e "\n 🟩 Creating deployment script..."
cp deploy.sh /var/www/$DOMAIN/deploy/deploy.sh

echo -e "\n 🟩 Setting permissions..."
chmod +x /var/www/$DOMAIN/deploy/deploy.sh

echo -e "\n 🟩 Setting ownership..."
chown -R www-data:www-data /var/www/$DOMAIN/deploy/deploy.sh

echo -e "\n ✅  Deployment script created for $DOMAIN."
