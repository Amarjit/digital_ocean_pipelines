#!/bin/bash

ENV_LIVE=".env-live"

# Function to update the .env file
update_env_var() {
    local var_name=$1
    local prompt_message=$2
    local default_value=$3

    # Check if the variable exists and prompt user to enter a value
    if ! grep -q "^${var_name}=" $ENV_LIVE; then
        echo -e "🟩  ${var_name} does not exist in $ENV_LIVE, adding it."
        echo "${var_name}=${default_value}" >> $ENV_LIVE
    fi

    echo -e "\n${prompt_message} (press Enter to skip): "
    read input_value

    # If input is empty, keep the existing value in the .env-live file
    if [ -z "$input_value" ]; then
        input_value=$(grep "^${var_name}=" $ENV_LIVE | cut -d '=' -f2)
    fi

    # Update .env-live file
    sed -i "s/^${var_name}=.*/${var_name}=${input_value}/" $ENV_LIVE
    echo "🟩  ${var_name} set to ${input_value}."
}

# Function to add GIT_REPO_URL to the .env-live file
add_git_repo_url() {
    local git_repo_url=$1
    local var_name="GIT_REPO_URL"

    # Remove any existing GIT_REPO_URL from the .env-live file
    sed -i "/^${var_name}=/d" $ENV_LIVE

    # Add GIT_REPO_URL to the end of the file
    echo "${var_name}=${git_repo_url}" >> $ENV_LIVE
    echo "🟩  ${var_name} set to ${git_repo_url}."
}

# Create a copy of the .env file to modify
echo -e "\n🟩  Creating a copy of the example .env file..."
cp .env $ENV_LIVE

# Prompt and update variables
echo -e "🟩  Starting to update the $ENV_LIVE file...\n"

update_env_var "DOMAIN" "Enter your domain (e.g., example.com)"
update_env_var "GIT_REPO_NAME" "Enter your Git repository name"
update_env_var "GIT_BRANCH_NAME" "Enter your Git branch name"
update_env_var "GIT_WEBHOOK_SECRET" "Enter your Git webhook secret"

# Prompt for GIT_REPO_URL and add it
echo -e "\nEnter your Git repository URL (e.g., https://github.com/user/repo.git): "
read GIT_REPO_URL
add_git_repo_url "$GIT_REPO_URL"

echo -e "\n🟩  All variables updated in $ENV_LIVE."

# Refresh the .env file in the current shell
echo -e "\n🟩  Loading the new .env file to current shell..."
source $ENV_LIVE

# Source the .env-live file to load variables
source $ENV_LIVE

# Check if the domain is set and folder exists.
echo -e "\n🟩  Checking if the domain folder exists..."
if [ -z "$DOMAIN" ]; then
    echo -e "\n🟥  DOMAIN variable is not set. Aborting..."
    rm -f $ENV_LIVE
    exit 1
elif [ ! -d "/var/www/$DOMAIN" ]; then
    echo -e "\n🟥  Domain folder does not exist. Cannot copy .env file. Aborting..."
    rm -f $ENV_LIVE
    exit 1
fi

# Move new .env file to the deployment folder. This is now available for scripts in domain folder.
echo -e "\n🟩  Moving updated .env file to domain folder..."
mv $ENV_LIVE /var/www/$DOMAIN/.env

# Check if the .env file is moved successfully
echo -e "\n🟩  Checking if domain .env file moved successfully..."
if [ -f "/var/www/$DOMAIN/.env" ]; then
    echo -e "\n✅  Env setup completed successfully"
else
    echo -e "\n🟥  Failed to move .env file to /var/www/$DOMAIN/.env. Aborting..."
    exit 1
fi

# Load the some .env variables in the current shell to mke it available for other scripts.
echo -e "\n🟩 Load ENV variables into shell"
source /var/www/$DOMAIN/.env
