#!/bin/bash

DOMAIN=$1

# Check if domain is provided.
if [ -z "$DOMAIN" ]; then
    echo -e "\n 🟥  Domain not supplied. Aborting"
    exit 1
fi

# Get env setup from user.
chmod +x setup/setup_env.sh
./setup/setup_env.sh $DOMAIN

# Create deployment script.
chmod +x setup/setup_deploy.sh
./setup/setup_deploy.sh $DOMAIN

# Create webhook recipient PHP script.
chmod +x setup/setup_webhook.sh
./setup/setup_webhook.sh $DOMAIN

# Setup webhook IP whitelisting.
chmod +x setup/setup_webhook_whitelist.sh
./setup/setup_webhook_whitelist.sh $DOMAIN

# Setup CRON job for deployment.
chmod +x setup/setup_cron.sh
./setup/setup_cron.sh $DOMAIN

# Notify user of setting up webhook, secret and how to test.
echo -e "\n ✅ Setup complete"
echo -e "\n 🟩 Ensure that you read the README to ensure you have setup GitHub Webhook and authentication correctly"
