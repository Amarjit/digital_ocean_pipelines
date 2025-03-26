#!/bin/bash

DOMAIN=$1

DEPLOY_PATH="/var/www/$DOMAIN/deploy"
DEPLOY_SCRIPT_PATH="$DEPLOY_PATH/deploy.sh"
ARTIFACTS_PATH="$DEPLOY_PATH/artifacts"

# Check if domain is provided.
if [ -z "$DOMAIN" ]; then
    echo -e "\n 🟥  Domain not supplied. Aborting"
    exit 1
fi

# Check deploy directory exists.
if [ ! -d "$DEPLOY_PATH" ]; then
    echo -e "\n 🟥  Deploy directory does not exist. Aborting"
    exit 1
fi

echo -e "\n 🟩  Creating deployment script"
cp setup/artifacts/deploy.sh $DEPLOY_SCRIPT_PATH
chown -R root:root $DEPLOY_SCRIPT_PATH
chmod 110 $DEPLOY_SCRIPT_PATH # execute only

echo -e "\n ✅  Deployment script created"
