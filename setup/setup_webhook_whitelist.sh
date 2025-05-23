#!/bin/bash

DOMAIN=$1
CERT_TYPE=$2

VHOST_SSL_FILE="002-$DOMAIN-le-ssl.conf"
VHOST_SSL_FILE_PATH="/etc/apache2/sites-enabled/$VHOST_FILE"

VHOST_SELF_CERT_FILE="002-$DOMAIN-selfsigned.conf"
VHOST_SELF_CERT_FILE_PATH="/etc/apache2/sites-enabled/$VHOST_SELF_CERT_FILE"

DOMAIN_DEPLOY_ENV="/var/www/$DOMAIN/deploy/.env"

# Check if domain is provided.
if [ -z "$DOMAIN" ]; then
    echo -e "\n 🟥  Domain not supplied. Aborting"
    exit 1
fi

# Check domain exists
if [ ! -d "/var/www/$DOMAIN" ]; then
    echo -e "\n 🟥  Domain does not exist. Aborting"
    exit 1
fi

# Check if domain environment variables exist.
if [[ ! -f "$DOMAIN_DEPLOY_ENV" ]]; then
    echo -e "\n 🟥  Domain environment variables not found. setup_env.sh must be run. Aborting"
    exit 1
fi

# Validate the certificate type.
if [[ "$CERT_TYPE" != "local" && "$CERT_TYPE" != "live" ]]; then
    echo -e "\n 🟥  Invalid certificate type. Must be 'local' or 'live'. Aborting"
    exit 1
fi

# Set VHOST_FILEPATH depending on local or remote
if [[ "$CERT_TYPE" == "local" ]]; then
    VHOST_FILEPATH="$VHOST_SELF_CERT_FILE_PATH"
elif [[ "$CERT_TYPE" == "live" ]]; then
    VHOST_FILEPATH="$VHOST_SSL_FILE_PATH"
fi

# Check if the vhost file exists.
if [[ ! -f "$VHOST_FILEPATH" ]]; then
    echo -e "\n 🟥  SSL vhost file not found. Please ensure that the SSL certificate is installed. Aborting"
    exit 1
fi

source $DOMAIN_DEPLOY_ENV

# Install JQ for JSON parsing.
echo -e "\n 🟩  Installing JQ for JSON parsing"
apt install -y jq > /dev/null 2>&1

# Fetch the IPs and extract webhook IP whitelist section from GitHub Meta API.
echo -e "\n 🟩  Fetching GitHub webhook whitelist IPs"
HOOK_IPS=$(curl -s "$GITHUB_META_URL" | jq -r '.hooks[]')

# Check if the response is valid
if [[ -z "$HOOK_IPS" ]]; then
    echo -e "\n 🟥  Failed to fetch GitHub webhook IPs. Aborting"
    exit 1
fi

# Prepare the IP list for the Apache config
echo -e "\n 🟩  Preparing IP list for Apache configuration"
IP_BLOCK=""
for ip in $HOOK_IPS; do
    IP_BLOCK="${IP_BLOCK}
            Require ip $ip"
done

# Define block <Files "webhook.php"> section.
echo -e "\n 🟩  Preparing webhook block"
WEBHOOK_BLOCK=$(cat <<EOF

    <Directory /var/www/$DOMAIN/public>
        <Files webhook.php>
            Require all denied

            # Allow GitHub's IP ranges
            $IP_BLOCK
        </Files>
    </Directory>
EOF
)

# Insert the entire webhook block below DocumentRoot. Duplicate <Directory> blocks are allowed.
echo -e "\n 🟩  Adding webhook IP whitelist block to vhost file"
TEMP_FILE="/tmp/webhook_block_$DOMAIN.tmp" # Temp file needs to be used because sed does not support various characters.
echo "$WEBHOOK_BLOCK" > "$TEMP_FILE"
sed -i "/DocumentRoot/r $TEMP_FILE" $VHOST_FILEPATH
rm "$TEMP_FILE"

# Output success message
echo -e "\n ✅  Webhook IP whitelist block added to vhost file"

# Reload Apache to apply the changes.
echo -e "\n 🟩 Reloading Apache configuration"
systemctl reload apache2

echo -e "\n ✅  GitHub webhook IP whitelisting complete"
