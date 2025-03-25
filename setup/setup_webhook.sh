#!/bin/bash

echo -e "\n 🟩  Setting up webhook recipient PHP script"

# Check log folder exists.
if [ ! -d "/var/www/$DOMAIN/logs" ]; then
    echo -e "\n 🟥  Logs directory does not exist. Aborting"
    exit 1
fi

# Paths
LOG_PATH="/var/www/$DOMAIN/logs"
ARTIFACTS_PATH="/var/www/$DOMAIN/deploy/artifacts"
PUBLIC_PATH="/var/www/$DOMAIN/public/"

echo -e "\n 🟩  Creating blank webhook logfile"
touch $LOG_PATH/webhook.log
chown www-data:www-data $LOG_PATH/webhook.log
chmod 200 $LOG_PATH/webhook.log # write-only

# Create webhook inside artifact folder so that it can be copied over for every fresh deployment.
echo -e "\n 🟩  Creating webhook artifact for use in deployment"
cp setup/artifacts/webhook.php $ARTIFACTS_PATH/webhook.php
chown www-data:www-data $ARTIFACTS_PATH/webhook.php
chmod 400 $ARTIFACTS_PATH/webhook.php # read-only

echo -e "\n 🟩  Copying webhook recipient PHP script to domain to allow for immediate website cloning"
cp setup/artifacts/webhook.php $PUBLIC_PATH/webhook.php
chown www-data:www-data $PUBLIC_PATH/webhook.php
chmod 400 $PUBLIC_PATH/webhook.php # read-only
chmod +x $PUBLIC_PATH/webhook.php

echo -e "\n 🟩  Replacing GitHub webhook secret key in webhook.php"
sed -i "s/SECRET_EXAMPLE/$GIT_WEBHOOK_SECRET/g" $PUBLIC_PATH/webhook.php

echo -e "\n ✅  Completed webook setup"
