#!/bin/bash

# Define the .env file
ENV_FILE="../.env"

# Create .env if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
    echo -e "\n 🟩 Creating .env file..."
    touch "$ENV_FILE"
fi

# Load existing .env variables
set -a
source "$ENV_FILE" 2>/dev/null
set +a

# Setup webhook IP whitelisting.
chmod +x setup/github_whitelist.sh
./setup/setup_github_whitelist.sh

# Create deployment script.
chmod +x setup/deploy/setup_deploy.sh
./setup/deploy/setup_deploy.sh

# Create webhook recipient PHP script.
chmod +x setup/webhook/setup_webhook.sh
./setup/webhook/setup_webhook.sh

# Notify user of setting up webhook, secret and how to test.
echo -e "\n 🟩 Setup complete."
echo -e "\n 🟩 Ensure that you read the README to ensure you have setup GitHub Webhook and authentication correctly."