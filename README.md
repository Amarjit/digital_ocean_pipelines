# Digital Ocean Pipelines Setup

This repository provides a way to automate your website deployment using Blue-Green deployment method.

## Prerequisites

- Server running Debian 12 (or similar Linux distribution)
- SSL must be enabled for the site. Why wouldn't you?
- Get repo details that contain your website
- Your public-facing files must be in a 'public' folder
- SSH public key-pair that belongs to your server. This should be added as a GitHub Deploy key
- Your website is hosted in GitHub (can be private)


## Configuration

First step is to ensure the website you want to copy over all resides in a folder named 'Public' at root. Default permissions will be applied to these files that only allow read-access. You can modify these permissions after deployment. It is suggested you modify the deploy.sh within your domain folder to tailor the permissions of your deployment. This script is used for refreshing deployments later on.

The next step is to add a read-only Deploy key to the website repository in GitHub:

  1. Navigate to Githib repository
  2. Settings
  3. Deploy keys
  4. Add deploy key
  5. Name the key to anything you want
  6. Paste your public SSH code from ~/.ssh/id_rsa
  7. Do not select write access
  8. Save

You must now setup your webhook that will call your website deployment script to make new deployments. Deployments are carried out on post-recieve (git push).

  1. Navigate to Githib repository
  2. Settings
  3. Webhooks
  4. Add webhook
  5. Enter your domain "webhook.php" appended. e.g. https://domain.com/webhook.php
  6. Enter a secret to increase security so only GitHub can access your deployments. IP Whiitelisting from GitHub will also be managed and enabled automatically.
  7. Enable SSL verification
  8. Select 'just the push event'
  9. Select 'Active'
  10. Add webhook
  11. You can test the first push by submitting a change in your website repo and pushing it. The default deployment time is every 5 minutes. Further requests can be replayed via the webhook settings in GitHub.
  12. Webhook logs can be found on the logs folder within the domain folder.

## Quickstart

Paste the single line command:

    echo ">>> Enter your domain: " && read DOMAIN && sudo apt install git -y > /dev/null 2>&1 && cd ~ && git clone https://github.com/Amarjit/digital_ocean_pipelines && cd digital_ocean_pipelines && chmod +x setup.sh && ./setup.sh "$DOMAIN"
