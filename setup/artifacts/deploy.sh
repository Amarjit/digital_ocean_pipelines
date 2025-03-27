#!/bin/bash

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo -e "\n 🟥  .env file not found. Aborting"
    exit 1
fi

# Lock file is required to ensure only one deployment can run at a time. Delete this lock file if gridlock occurs.
DEPLOY_FLAG_PATH="/var/www/$DOMAIN/deploy/flags"
DEPLOY_LOCK_FILENAME="deploy.lock"
DEPLOY_LOCK_FILE="$DEPLOY_FLAG_PATH/$DEPLOY_LOCK_FILENAME"

# Deploy flag is not required to run deployment. However, we should remove the flag at end of deployment as it's been carried out.
DEPLOY_WEBONLY_FLAG_PATH="$DEPLOY_FLAG_PATH/web"
DEPLOY_FILENAME="deploy"
DEPLOY_FILE="$DEPLOY_WEBONLY_FLAG_PATH/$DEPLOY_FILENAME"

# Ensure $DOMAIN is set
if [ -z "$DOMAIN" ]; then
    echo -e "\n 🟥  DOMAIN variable is not set. Aborting"
    exit 1
fi

if [ -f "$DEPLOY_LOCK_FILE" ]; then
    echo -e "\n 🟥  Deployment already in progress. Aborting"
    exit 1
fi

# Create lock file so that only one deployment can run at a time.
echo -e "\n 🟩  Locking deployment with lock file"
touch "$DEPLOY_LOCK_FILE"

# Deployment paths
GREEN_CANDICATE_PATH="/var/www/$DOMAIN/deploy/green__candicate"  
LIVE_PATH="/var/www/$DOMAIN/public"
BLUE_PATH="/var/www/$DOMAIN/public__blue"
GREEN_PATH="/var/www/$DOMAIN/public__green"

# Cleanup previous deployments
echo -e "\n 🟩  Cleaning-up previous deployments"
rm -rf "$GREEN_CANDICATE_PATH" # Remove latest deployment folder
rm -rf "$GREEN_PATH" # Remove green deployment if it exists
rm -rf "$BLUE_PATH" # Remove blue deployment if it exists

# Get the latest changes from the repository
echo -e "\n 🟩  Fetching latest changes from GitHub"
mkdir -p "$GREEN_CANDICATE_PATH"
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" \
git clone --branch "$GIT_BRANCH_NAME" "$GIT_REPO_URL" "$GREEN_CANDICATE_PATH"

# Check public folder exists in green candicate
if [ ! -d "$GREEN_CANDICATE_PATH/public" ]; then
    echo -e "\n 🟥  Website must have 'public' folder"
    echo -e "\n 🟥  Public folder not found in green candicate. Aborting"

    # Cleanup
    echo -e "\n 🟥  Cleaning-up deployment"
    rm -rf "$GREEN_CANDICATE_PATH"
    rm -f "$DEPLOY_LOCK_FILE"

    echo -e "\n 🟥  Deployment failed"
    exit 1
fi

# Grab artifacts.
echo -e "\n 🟩  Fetching public artifacts for green candicate"
cp -r /var/www/$DOMAIN/deploy/artifacts/web/ "$GREEN_CANDICATE_PATH/public"

# Move green-candicate public to green
echo -e "\n 🟩  Deploying green-candicate to GREEN deployment"
mkdir -p "$GREEN_PATH"
cp -r "$GREEN_CANDICATE_PATH"/public/ "$GREEN_PATH"

# Set the correct permissions
echo -e "\n 🟩  Setting permissions for GREEN deployment"
chown root:www-data "$GREEN_PATH"
chmod 550 "$GREEN_PATH"
chown -R root:www-data "$GREEN_PATH/*"
chmod -R 440 "$GREEN_PATH/*"

# Move the current live to blue
echo -e "\n 🟩  Moving current LIVE to BLUE deployment"
echo -e "\n 🟥  Site will be down momentarily"
if [ -d "$LIVE_PATH" ]; then
    mv "$LIVE_PATH" "$BLUE_PATH"
    chown -R root:root "$BLUE_PATH"
    chmod -R 440 "$BLUE_PATH"
else
    echo -e "\n 🟥  No current LIVE deployment found. Skipping BLUE deployment"
fi

# Deploy the latest green deployment to live path
echo -e "\n 🟩  Deploying GREEN to LIVE"
mv "$GREEN_PATH" "$LIVE_PATH"
chown root:www-data "$LIVE_PATH"
chmod 550 "$LIVE_PATH"
chown -R root:www-data "$LIVE_PATH/*"
chmod -R 440 "$LIVE_PATH"/*
find "$LIVE_PATH" -type d -exec chmod 550 {} + # Fix directories inside LIVE so they are traversable

# Delete the lock file
echo -e "\n 🟩  Removing deployment lock file"
rm -f "$DEPLOY_LOCK_FILE"

# Remove the deploy flag
echo -e "\n 🟩  Removing webhook deploy flag"
rm -f "$DEPLOY_FILE"

echo -e "\n ✅  Deployment completed successfully"
echo -e "\n ✅  Website is live"
