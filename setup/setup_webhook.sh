#!/bin/bash

DOMAIN=$1

DOMAIN_PATH="/var/www/$DOMAIN"
LOG_PATH="/var/www/$DOMAIN/logs"
ARTIFACTS_PATH="/var/www/$DOMAIN/deploy/artifacts"
ARTIFACTS_WEB_PATH="$ARTIFACTS_PATH/web"
PUBLIC_PATH="/var/www/$DOMAIN/public"
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
chown root:www-data $LOG_PATH/webhook.log
chmod 220 $LOG_PATH/webhook.log # write-only

# Create webhook inside artifact web folder so that it can be copied over for every fresh deployment.
echo -e "\n 🟩  Creating public artifacts (i.e. callable webhook)"
cp -r setup/artifacts/public/ $ARTIFACTS_WEB_PATH/
chown -R root:root $ARTIFACTS_WEB_PATH/*
chmod -R 440 $ARTIFACTS_WEB_PATH/* # read-only

# Replace Github webhook secret key directly in file. It is only executable and cannot be read by www-data.
echo -e "\n 🟩  Replacing GitHub webhook secret key"
sed -i "s/SECRET_EXAMPLE/$GIT_WEBHOOK_SECRET/g" $ARTIFACTS_WEB_PATH/webhook.php

echo -e "\n 🟩  Copying public artifacts and webhook to domain for immediate website setup"
cp -r $ARTIFACTS_WEB_PATH/ $PUBLIC_PATH/
chown -R root:www-data $PUBLIC_PATH/*
chmod 440 $PUBLIC_PATH/webhook.php # read-only
find $PUBLIC_PATH -type d -exec chmod 550 {} \; # Fix directories inside LIVE so they are traversable

echo -e "\n ✅  Completed webook setup"
