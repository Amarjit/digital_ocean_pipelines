#!/bin/bash

# Install JQ for JSON parsing.
echo -e "\n 🟩  Installing JQ for JSON parsing..."
apt install -y jq

# Fetch the IPs and extract webhook IP whitelist section from GitHub Meta API.
echo -e "\n 🟩  Fetching GitHub webhook whitelist IPs..."
HOOK_IPS=$(curl -s "$GITHUB_META_URL" | jq -r '.hooks[]')

# Check if the response is valid
if [[ -z "$HOOK_IPS" ]]; then
    echo -e "\n 🟥  Failed to fetch GitHub webhook IPs."
    exit 1
fi

# Prepare the IP list for the Apache config
echo -e "\n 🟩  Preparing IP list for Apache configuration..."
IP_BLOCK=""
for ip in $HOOK_IPS; do
    IP_BLOCK="$IP_BLOCK\n            Require ip $ip"
done

# Define the block to update the <Files "webhook.php"> section
WEBHOOK_BLOCK=$(cat <<EOF
        <Files "webhook.php">
            Require all denied
            # Allow GitHub's IP ranges (use the most current ones from GitHub)
$IP_BLOCK
        </Files>
EOF
)

# SSL Vhost.
VHOST_FILE="/etc/apache2/sites-enabled/001-$DOMAIN-le-ssl.conf"

# Check if the vhost file contains the <Directory "/var/www/$DOMAIN/public/"> block
echo -e "\n 🟩  Figuring how to add webhook whitelist to vhosts..."

if ! grep -q '<Directory "/var/www/$DOMAIN/public">' $VHOST_FILE; then
    # If it doesn't exist, create the <Directory> block
    echo -e "\n 🟩 Creating <Directory> block for /var/www/$DOMAIN/public/..."
    cat <<EOF >> $VHOST_FILE
    <Directory "/var/www/$DOMAIN/public">
        #
    </Directory>
EOF
    echo "Created <Directory> block for /var/www/$DOMAIN/public/"
fi

# Check if the vhost file contains the <Files "webhook.php"> block
if grep -q '<Files "webhook.php">' $VHOST_FILE; then
    # If it exists, replace the existing block
    sed -i "/<Files \"webhook.php\">/,/<\/Files>/c\\
$WEBHOOK_BLOCK" $VHOST_FILE
    echo -e "\n 🟩  Updated the IP whitelist block for webhook.php in the vhost file."
else
    # If not, add the block inside the <Directory> section
    sed -i "/<Directory \"\/var\/www\/$DOMAIN\/public\/\">/a\\
$WEBHOOK_BLOCK" $VHOST_FILE
    echo -e "\n 🟩  Added the IP whitelist block for webhook.php to the vhost file."
fi

# Reload Apache to apply the changes.
echo -e "\n 🟩 Reloading Apache configuration..."
systemctl reload apache2
echo "Apache configuration reloaded."

echo -e "\n ✅  GitHub webhook IP whitelisting complete."
