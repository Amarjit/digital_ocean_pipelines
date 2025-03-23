#!/bin/bash

# Deployment paths
LATEST_DEPLOYMENT="/var/www/$DOMAIN/deployment/"  
CURRENT_PATH="/var/www/$DOMAIN/public"
BLUE_PATH="/var/www/$DOMAIN/public--blue"
GREEN_PATH="/var/www/$DOMAIN/public--green"

# Cleanup previous deployments (ensure you're not accidentally removing anything important)
echo "Cleaning up previous deployments..."
rm -rf "$LATEST_DEPLOYMENT"  # Remove the latest deployment folder
rm -rf "$GREEN_PATH"        # Remove the green deployment if it exists
rm -rf "$BLUE_PATH"         # Remove the blue deployment if it exists

# Get the latest changes from the repository
echo "Fetching latest changes from GitHub..."
mkdir -p "$LATEST_DEPLOYMENT"
git clone "$WEBSITE_GIT_URL" "$LATEST_DEPLOYMENT"

# Move the new changes to a green deployment
echo "Moving new changes to green deployment..."
mkdir -p "$GREEN_PATH"
cp -r "$LATEST_DEPLOYMENT"/* "$GREEN_PATH"
chown -R www-data:www-data "$GREEN_PATH"
chmod -R 755 "$GREEN_PATH"

# Move the current live to blue
echo "Moving current live to blue deployment..."
if [ -d "$CURRENT_PATH" ]; then
    mv "$CURRENT_PATH" "$BLUE_PATH"
    chown -R root:root "$BLUE_PATH"
    chmod -R 700 "$BLUE_PATH"
else
    echo "Warning: No current live deployment found, skipping blue deployment."
fi

# Deploy the latest green deployment to the current live path
echo "Deploying the green deployment to the current live path..."
mv "$GREEN_PATH" "$CURRENT_PATH"
chown -R www-data:www-data "$CURRENT_PATH"
chmod -R 755 "$CURRENT_PATH"

echo "Deployment completed successfully."
