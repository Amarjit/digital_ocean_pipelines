#!/bin/bash

DOMAIN=$1
DEPLOY_FILE="/var/www/$DOMAIN/deploy/deploy.sh"
CRONTAB_FILENAME="$DOMAIN"_blue_green_deploy
CRONTAB_FILE="/etc/cron.d/$CRONTAB_FILENAME"

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

# Set cron.d to run every 1 minute
echo -e "\n 🟩  Setting up CRON job for blue-green deployment"
echo "*/5 * * * * root $DEPLOY_FILE $DOMAIN" > $CRONTAB_FILE

if [ -f "$CRONTAB_FILE" ]; then
    echo -e "\n ✅  CRON job setup"
else
    echo -e "\n 🟥  CRON job setup failed. Retry"
fi
