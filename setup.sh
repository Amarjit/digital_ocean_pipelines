#!/bin/bash

# Get env setup from user.
chmod +x setup/setup_env.sh
source setup/setup_env.sh

# Get environment variables.
source .env

# Create deployment script.
chmod +x setup/setup_deploy.sh
./setup/setup_deploy.sh $DOMAIN

# Create webhook recipient PHP script.
chmod +x setup/setup_webhook.sh
./setup/setup_webhook.sh

# Setup webhook IP whitelisting.
chmod +x setup/setup_github_whitelist.sh
./setup/setup_webhook_whitelist.sh $DOMAIN

# Notify user of setting up webhook, secret and how to test.
echo -e "\n ✅ Setup complete"
echo -e "\n 🟩 Ensure that you read the README to ensure you have setup GitHub Webhook and authentication correctly"
