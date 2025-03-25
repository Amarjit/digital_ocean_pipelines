#!/bin/bash

# Load environment variables
source ../.env

DEPLOY_FLAGS_PATH="/var/www/$DOMAIN/deploy/flags"

# Deploy flag is not required to run deployment. However, we should remove the flag at end of deployment to indicate dpeloyment is complete and not required again.
DEPLOY_FILENAME="deploy"
DEPLOY_FILE="$DEPLOY_FLAGS_PATH/$DEPLOY_FILENAME"

# Lock file is required to ensure only one deployment can run at a time. Delete this lock file if gridlock occurs.
DEPLOY_LOCK_FILENAME="deploy.lock"
DEPLOY_LOCK_FILE="$DEPLOY_FLAGS_PATH/$DEPLOY_LOCK_FILENAME"

# Ensure $DOMAIN is set
if [ -z "$DOMAIN" ]; then
    echo -e "\n ⚠️  DOMAIN variable is not set. Aborting  ⚠️"
    rm -f "$DEPLOY_LOCK_FILE"
    exit 1
fi

if [ -f "$DEPLOY_LOCK_FILE" ]; then
    echo -e "\n ⚠️  Looks like deployment already in progress. Aborting  ⚠️"
    exit 1
fi

# Create lock file so that only one deployment can run at a time.
echo -e "\n 🟩  Creating deployment lock file"
touch "$DEPLOY_LOCK_FILE"

# Deployment paths
LATEST_DEPLOYMENT="/var/www/$DOMAIN/deploy/latest"  
LIVE_PATH="/var/www/$DOMAIN/public"
BLUE_PATH="/var/www/$DOMAIN/public--blue"
GREEN_PATH="/var/www/$DOMAIN/public--green"

# Cleanup previous deployments (ensure you're not accidentally removing anything important)
echo -e "\n 🟩  Cleaning up previous deployments"
rm -rf "$LATEST_DEPLOYMENT" # Remove the latest deployment folder
rm -rf "$GREEN_PATH"        # Remove the green deployment if it exists
rm -rf "$BLUE_PATH"         # Remove the blue deployment if it exists

# Get the latest changes from the repository
echo -e "\n 🟩  Fetching latest changes from GitHub"
mkdir -p "$LATEST_DEPLOYMENT"
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" \
git clone "$GIT_REPO_URL" "$LATEST_DEPLOYMENT"

# Copy artifacts over to latest.
echo -e "\n 🟩  Copying artifacts to latest deployment"
cp -r /var/www/$DOMAIN/deploy/artifacts/* "$LATEST_DEPLOYMENT/public"

# Move the new changes to a green deployment
echo -e "\n 🟩  Moving new changes to GREEN deployment"
mkdir -p "$GREEN_PATH"
cp -r "$LATEST_DEPLOYMENT"/public/* "$GREEN_PATH"

# Set the correct permissions
echo -e "\n 🟩  Setting of permissions of latest changes"
chown -R www-data:www-data "$GREEN_PATH"
chmod 500 "$GREEN_PATH"
chmod -R 400 "$GREEN_PATH"
chown -R www-data:www-data "$GREEN_PATH"

# Move the current live to blue
echo -e "\n 🟩  Moving current LIVE to BLUE deployment"
echo -e "\n ⚠️  Site will be down momentarily  ⚠️"
if [ -d "$LIVE_PATH" ]; then
    mv "$LIVE_PATH" "$BLUE_PATH"
    chown -R root:root "$BLUE_PATH"
    chmod -R 400 "$BLUE_PATH"
else
    echo -e "\n ⚠️  Warning: No current LIVE deployment found, skipping BLUE deployment.  ⚠️"
fi

# Deploy the latest green deployment to live path
echo -e "\n 🟩  Deploying GREEN deployment to LIVE"
mv "$GREEN_PATH" "$LIVE_PATH"
chown -R www-data:www-data "$LIVE_PATH"
chmod 500 "$LIVE_PATH"
chmod -R 400 "$LIVE_PATH"/*
find "$LIVE_PATH" -type d -exec chmod 500 {} +  # Fix directories inside LIVE

# Delete the lock file
echo -e "\n 🟩  Removing deployment lock file"
rm -f "$DEPLOY_LOCK_FILE"

# Remove the deploy flag
echo -e "\n 🟩  Removing deploy flag to allow new deployments"
rm -f "$DEPLOY_FILE"

echo -e "\n ✅  Deployment completed successfully"
echo -e "\n ⚠️  Check site is live  ⚠️"
