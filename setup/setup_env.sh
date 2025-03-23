#!/bin/bash

# Function to update the .env file
update_env_var() {
    local var_name=$1
    local prompt_message=$2
    local default_value=$3

    # Check if the variable exists and prompt user to enter a value
    if ! grep -q "^${var_name}=" .env; then
        echo -e "🟩  ${var_name} does not exist in .env, adding it."
        echo "${var_name}=${default_value}" >> .env
    fi

    echo -e "\n${prompt_message} (press Enter to skip): "
    read input_value

    # If input is empty, keep the existing value in the .env file
    if [ -z "$input_value" ]; then
        input_value=$(grep "^${var_name}=" .env | cut -d '=' -f2)
    fi

    # Update .env file
    sed -i "s/^${var_name}=.*/${var_name}=${input_value}/" .env
    echo "🟩  ${var_name} set to ${input_value}."
}

# Prompt and update variables
echo -e "🟩  Starting to update the .env file...\n"

update_env_var "DOMAIN" "Enter your domain (e.g., example.com)"
update_env_var "GIT_REPO_URL" "Enter your Git repository URL"
update_env_var "GIT_REPO_NAME" "Enter your Git repository name"
update_env_var "GIT_BRANCH_NAME" "Enter your Git branch name"
update_env_var "GIT_WEBHOOK_SECRET" "Enter your Git webhook secret"

echo -e "\n🟩  All variables updated in .env."
