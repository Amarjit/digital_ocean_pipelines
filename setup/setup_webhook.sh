#!/bin/bash

DOMAIN=$1

DOMAIN_PATH="/var/www/$DOMAIN"
LOG_PATH="/var/www/$DOMAIN/logs"
ARTIFACTS_PATH="/var/www/$DOMAIN/deploy/artifacts"
PUBLIC_PATH="/var/www/$DOMAIN/public/"
DOMAIN_DEPLOY_ENV="/var/www/$DOMAIN/deploy/.env"

# Check if domain is provided.
if [ -z "$DOMAIN" ]; then
    echo -e "\n 🟥  Domain not supplied. Aborting"
    exit 1
fi

# Check domain exists
if [ ! -d "$DOMAIN_PATH" ]; then
    echo -e "\n 🟥  Domain does not exist. Aborting"
    exit 1
fi

# Check if domain environment variables exist.
if [[ ! -f "$DOMAIN_DEPLOY_ENV" ]]; then
    echo -e "\n 🟥  Domain environment variables not found. setup_env.sh must be run. Aborting"
    exit 1
fi

# Check log folder exists.
if [ ! -d "$LOG_PATH" ]; then
    echo -e "\n 🟥  Logs directory does not exist. Aborting"
    exit 1
fi

source $DOMAIN_DEPLOY_ENV

echo -e "\n 🟩  Setting up webhook recipient PHP script"

echo -e "\n 🟩  Creating blank webhook logfile"
touch $LOG_PATH/webhook.log
chown www-data:www-data $LOG_PATH/webhook.log
chmod 200 $LOG_PATH/webhook.log # write-only

# Create webhook inside artifact folder so that it can be copied over for every fresh deployment.
echo -e "\n 🟩  Creating webhook artifacts"
cp setup/artifacts/webhook.php $ARTIFACTS_PATH/webhook.php
chown root:root $ARTIFACTS_PATH/webhook.php
chmod 500 $ARTIFACTS_PATH/webhook.php # executable + read

echo -e "\n 🟩  Copying webhook to domain for immediate website setup"
cp setup/artifacts/webhook.php $PUBLIC_PATH/webhook.php
chown www-data:www-data $PUBLIC_PATH/webhook.php
chmod 500 $PUBLIC_PATH/webhook.php # executable + read

# Replace Github webhook secret key directly in file. It is only executable and cannot be read by www-data.
echo -e "\n 🟩  Replacing GitHub webhook secret key in webhook.php"
sed -i "s/SECRET_EXAMPLE/$GIT_WEBHOOK_SECRET/g" $PUBLIC_PATH/webhook.php

echo -e "\n ✅  Completed webook setup"
