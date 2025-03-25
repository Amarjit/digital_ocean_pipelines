#!/bin/bash

# Check deploy directory exists.
if [ ! -d "/var/www/$DOMAIN/deploy" ]; then
    echo -e "\n 🟥  Deploy directory does not exist. Aborting"
    exit 1
fi

# Paths
DEPLOY_PATH="/var/www/$DOMAIN/deploy"
ARTIFACTS_PATH="$DEPLOY_PATH/artifacts"

echo -e "\n 🟩  Creating deployment script"
cp setup/artifacts/deploy.sh $DEPLOY_PATH/deploy.sh
chmod 500 $DEPLOY_PATH/deploy.sh # read and execute
chown -R root:root $DEPLOY_PATH/deploy.sh

echo -e "\n ✅  Deployment script created"
