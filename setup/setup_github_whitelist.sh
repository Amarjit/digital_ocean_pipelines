#!/bin/bash

# Fetch the IPs and extract the 'hooks' section from GitHub API.
HOOK_IPS=$(curl -s "$GITHUB_META_URL" | jq -r '.hooks[]')

# Check if the response is valid
if [[ -z "$HOOK_IPS" ]]; then
    echo -e "\n 🟩 Failed to fetch GitHub webhook IPs."
    exit 1
fi

# Prepare the IP list for the Apache config
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

# Check if the vhost file contains the <Directory "/var/www/$DOMAIN/public/"> block
if ! grep -q '<Directory "/var/www/$DOMAIN/public/">' $VHOST_FILE; then
    # If it doesn't exist, create the <Directory> block
    echo -e "\n 🟩 Creating <Directory> block for /var/www/$DOMAIN/public/..."
    cat <<EOF >> $VHOST_FILE
<Directory "/var/www/$DOMAIN/public/">
    # Your existing directives (e.g., AllowOverride, etc.)
</Directory>
EOF
    echo "Created <Directory> block for /var/www/$DOMAIN/public/"
fi

# Check if the vhost file contains the <Files "webhook.php"> block
if grep -q '<Files "webhook.php">' $VHOST_FILE; then
    # If it exists, replace the existing block
    sed -i "/<Files \"webhook.php\">/,/<\/Files>/c\\
$WEBHOOK_BLOCK" $VHOST_FILE
    echo "Updated the IP whitelist block for webhook.php in the vhost file."
else
    # If not, add the block inside the <Directory> section
    sed -i "/<Directory \"\/var\/www\/$DOMAIN\/public\/\">/a\\
$WEBHOOK_BLOCK" $VHOST_FILE
    echo "Added the IP whitelist block for webhook.php to the vhost file."
fi

# Reload Apache to apply the changes
systemctl reload apache2
echo "Apache configuration reloaded."

echo -e "\n ✅  GitHub webhook IP whitelisting complete."
