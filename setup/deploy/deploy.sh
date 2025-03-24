#!/bin/bash

# Deployment paths
LATEST_DEPLOYMENT="/var/www/$DOMAIN/deploy/latest"  
LIVE_PATH="/var/www/$DOMAIN/public"
BLUE_PATH="/var/www/$DOMAIN/public--blue"
GREEN_PATH="/var/www/$DOMAIN/public--green"

# Cleanup previous deployments (ensure you're not accidentally removing anything important)
echo -e "\n 🟩  Cleaning up previous deployments..."
rm -rf "$LATEST_DEPLOYMENT" # Remove the latest deployment folder
rm -rf "$GREEN_PATH"        # Remove the green deployment if it exists
rm -rf "$BLUE_PATH"         # Remove the blue deployment if it exists

# Get the latest changes from the repository
echo -e "\n 🟩  Fetching latest changes from GitHub..."
mkdir -p "$LATEST_DEPLOYMENT"
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" \
git clone "$WEBSITE_GIT_URL" "$LATEST_DEPLOYMENT"

# Set the correct permissions
echo -e "\n 🟩  Setting of permissions of latest changes..."
chown -R www-data:www-data "$LATEST_DEPLOYMENT"
chmod 500 "$LATEST_DEPLOYMENT"
chmod -R 400 "$LATEST_DEPLOYMENT"
chown -R www-data:www-data "$LATEST_DEPLOYMENT"

# Move the new changes to a green deployment
echo -e "\n 🟩  Moving new changes to GREEN deployment..."
mkdir -p "$GREEN_PATH"
cp -r "$LATEST_DEPLOYMENT"/public/* "$GREEN_PATH"

# Move the current live to blue
echo -e "\n 🟩  Moving current LIVE to BLUE deployment...."
echo -e "\n ⚠️  Site will be down momentarily  ⚠️"
if [ -d "$LIVE_PATH" ]; then
    mv "$LIVE_PATH" "$BLUE_PATH"
    chown -R root:root "$BLUE_PATH"
    chmod -R 400 "$BLUE_PATH"
else
    echo -e "\n ⚠️  Warning: No current LIVE deployment found, skipping BLUE deployment.  ⚠️"
fi

# Deploy the latest green deployment to live path
echo -e "\n 🟩  Deploying GREEN deployment to LIVE..."
mv "$GREEN_PATH" "$LIVE_PATH"
chown -R www-data:www-data "$LIVE_PATH"
chmod 500 "$LIVE_PATH"
chmod -R 400 "$LIVE_PATH"/*
find "$LIVE_PATH" -type d -exec chmod 500 {} +  # Fix directories inside LIVE

echo -e "\n ✅  Deployment completed successfully."
echo -e "\n ⚠️  Check site is live  ⚠️"
