#!/bin/bash

# Get env setup from user.
chmod +x setup/setup_env.sh
source setup/setup_env.sh  # source - we need env variables available in this script.

# Setup webhook IP whitelisting.
chmod +x setup/setup_github_whitelist.sh
./setup/setup_github_whitelist.sh

# Create deployment script.
chmod +x setup/deploy/setup_deploy.sh
./setup/deploy/setup_deploy.sh

# Create webhook recipient PHP script.
chmod +x setup/webhook/setup_webhook.sh
./setup/webhook/setup_webhook.sh

# Notify user of setting up webhook, secret and how to test.
echo -e "\n ✅ Setup complete."
echo -e "\n 🟩 Ensure that you read the README to ensure you have setup GitHub Webhook and authentication correctly."