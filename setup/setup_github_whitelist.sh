#!/bin/bash

# Install JQ for JSON parsing.
echo -e "\n 🟩  Installing JQ for JSON parsing"
apt install -y jq

# Fetch the IPs and extract webhook IP whitelist section from GitHub Meta API.
echo -e "\n 🟩  Fetching GitHub webhook whitelist IPs"
HOOK_IPS=$(curl -s "$GITHUB_META_URL" | jq -r '.hooks[]')

# Check if the response is valid
if [[ -z "$HOOK_IPS" ]]; then
    echo -e "\n 🟥  Failed to fetch GitHub webhook IPs"
    exit 1
fi

# Prepare the IP list for the Apache config
echo -e "\n 🟩  Preparing IP list for Apache configuration"
IP_BLOCK=""
for ip in $HOOK_IPS; do
    IP_BLOCK="$IP_BLOCK\n            Require ip $ip"
done

# SSL Vhost.
VHOST_FILE="002-$DOMAIN-le-ssl.conf"
VHOST_FILEPATH="/etc/apache2/sites-enabled/$VHOST_FILE"

# Check if the vhost file exists.
if [[ ! -f "$VHOST_FILEPATH" ]]; then
    echo -e "\n 🟥  SSL vhost file not found. Please ensure that the SSL certificate is installed. Aborting"
    exit 1
fi

# Define block <Files "webhook.php"> section. We need to escape special characters becaus sed makes me mad. Newlines need to be handled carefully (using newline SED 'trick').
echo -e "\n 🟩  Preparing webhook block"
WEBHOOK_BLOCK="\n    <Directory /var/www/$DOMAIN/public>\n        <Files webhook.php>\n            Require all denied\n\n            # Allow GitHubs IP ranges    $IP_BLOCK\n        </Files>\n    </Directory>"
ESCAPED_WEBHOOK_BLOCK=$(echo "$WEBHOOK_BLOCK" | sed \
    -e ':a' \
    -e 'N' \
    -e 's/\n/NEWLINE/g' \
    -e 's/"/LEFTQUOTE/g' \
    -e "s/'/RIGHTQUOTE/g" \
    -e 's/\./DOT/g' \
    -e 's/:/COLON/g' \
    -e 's/\\/BACKSLASH/g' \
    -e 's/\//SLASH/g' \
    -e 's/</LEFTANGLE/g' \
    -e 's/>/RIGHTANGLE/g' \
    -e 's/#/HASH/g')

# Insert the entire webhook block below DocumentRoot. Duplicate <Directory> blocks are allowed.
echo -e "\n 🟩  Adding webhook IP whitelist block to vhost file"
sed -i "/DocumentRoot/a\\
$ESCAPED_WEBHOOK_BLOCK" $VHOST_FILEPATH

# Replace the placeholders in the vhost file.
echo -e "\n 🟩  Replacing placeholders in vhost file"
sed -i \
    -e 's/NEWLINE/\n/g' \
    -e 's/LEFTQUOTE/"/g' \
    -e 's/RIGHTQUOTE/'\''/g' \
    -e 's/DOT/\./g' \
    -e 's/COLON/:/g' \
    -e 's/BACKSLASH/\\/g' \
    -e 's/SLASH/\//g' \
    -e 's/LEFTANGLE/</g' \
    -e 's/RIGHTANGLE/>/g' \
    -e 's/HASH/#/g' \
    $VHOST_FILEPATH

# Output success message
echo -e "\n ✅  Webhook IP whitelist block added or updated in vhost file"

# Reload Apache to apply the changes.
echo -e "\n 🟩 Reloading Apache configuration"
systemctl reload apache2
echo "Apache configuration reloaded"

echo -e "\n ✅  GitHub webhook IP whitelisting complete"
