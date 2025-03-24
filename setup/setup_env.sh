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

# Function to add GIT_REPO_URL to the .env file
add_git_repo_url() {
    local git_repo_url=$1
    local var_name="GIT_REPO_URL"

    # Remove any existing GIT_REPO_URL from the .env file
    sed -i "/^${var_name}=/d" .env

    # Add GIT_REPO_URL to the end of the file
    echo "${var_name}=${git_repo_url}" >> .env
    echo "🟩  ${var_name} set to ${git_repo_url}."
}

# Prompt and update variables
echo -e "🟩  Starting to update the .env file...\n"

update_env_var "DOMAIN" "Enter your domain (e.g., example.com)"
update_env_var "GIT_REPO_NAME" "Enter your Git repository name"
update_env_var "GIT_BRANCH_NAME" "Enter your Git branch name"
update_env_var "GIT_WEBHOOK_SECRET" "Enter your Git webhook secret"

# Prompt for GIT_REPO_URL and add it
echo -e "\nEnter your Git repository URL (e.g., https://github.com/user/repo.git): "
read GIT_REPO_URL
add_git_repo_url "$GIT_REPO_URL"

echo -e "\n🟩  All variables updated in .env."
