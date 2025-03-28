#!/bin/bash

DOMAIN=$1
DEPLOY_FILE="/var/www/$DOMAIN/deploy/deploy.sh"

# Check domain.
if [ -z "$DOMAIN" ]; then
    echo -e "\n 🟥  Domain not supplied. Aborting"
    exit 1
fi

# Check domain exists.
if [ ! -d "/var/www/$DOMAIN" ]; then
    echo -e "\n 🟥  Domain does not exist. Aborting"
    exit 1
fi

# Check deploy.sh exists
if [ ! -f "$DEPLOY_FILE" ]; then
    echo -e "\n 🟥  Deploy file not found. Aborting"
    exit 1
fi

# Convert to alphanumeric, allow underscores, convert dots to underscores
CRONTAB_FILENAME="$DOMAIN"_deploy
CRONTAB_FILENAME=$(echo "$CRONTAB_FILENAME" | tr -cd '[:alnum:]_.' | tr '.' '_')
CRONTAB_FILE="/etc/cron.d/$CRONTAB_FILENAME"
DEPLOY_WEBONLY_FLAG_PATH="/var/www/$DOMAIN/deploy/flags/web/deploy"

# Set cron.d to run every 1 minute and only if the deploy web flag is set.
echo -e "\n 🟩  Setting up CRON job for blue-green deployment"
echo "*/5 * * * * root [ -f $DEPLOY_WEBONLY_FLAG_PATH ] && $DEPLOY_FILE $DOMAIN" > $CRONTAB_FILE

if [ -f "$CRONTAB_FILE" ]; then
    echo -e "\n ✅  CRON job setup"
else
    echo -e "\n 🟥  CRON job setup failed. Retry"
fi
