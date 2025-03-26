#!/bin/bash

$DOMAIN=$1

VHOST_FILE="002-$DOMAIN-le-ssl.conf"
VHOST_FILEPATH="/etc/apache2/sites-enabled/$VHOST_FILE"


# Check if domain is provided.
if [ -z "$DOMAIN" ]; then
    echo -e "\n 🟥  Domain not supplied. Aborting"
    exit 1
fi

# Check if the vhost file exists.
if [[ ! -f "$VHOST_FILEPATH" ]]; then
    echo -e "\n 🟥  SSL vhost file not found. Please ensure that the SSL certificate is installed. Aborting"
    exit 1
fi

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
    IP_BLOCK="$IP_BLOCK\n            Require ip $ip"
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
sed -i "/DocumentRoot/a\\
$WEBHOOK_BLOCK" $VHOST_FILEPATH

# Output success message
echo -e "\n ✅  Webhook IP whitelist block added to vhost file"

# Reload Apache to apply the changes.
echo -e "\n 🟩 Reloading Apache configuration"
systemctl reload apache2

echo -e "\n ✅  GitHub webhook IP whitelisting complete"
