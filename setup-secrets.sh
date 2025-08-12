#!/bin/bash

# Setup script for BLU_Classic GitHub Secrets
# This script helps configure the required secrets for automated releases

echo "================================================"
echo "BLU_Classic - GitHub Secrets Setup"
echo "================================================"
echo ""
echo "This script will help you set up the required secrets for:"
echo "- CurseForge uploads"
echo "- WoWInterface uploads"
echo "- Wago.io uploads"
echo "- Discord notifications"
echo ""
echo "You'll need your API tokens ready. If you don't have them:"
echo "- CurseForge: https://authors.curseforge.com/account/api-tokens"
echo "- Wago.io: https://addons.wago.io/account/apikeys"
echo "- WoWInterface: https://www.wowinterface.com/downloads/filecpl.php?action=apitokens"
echo "- Discord Webhook: From your Discord server settings"
echo ""
read -p "Press Enter to continue..."

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "ERROR: GitHub CLI (gh) is not installed."
    echo "Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "ERROR: Not authenticated with GitHub CLI."
    echo "Please run: gh auth login"
    exit 1
fi

REPO="DonnieDice/BLU_Classic"
echo ""
echo "Setting up secrets for repository: $REPO"
echo ""

# Function to set a secret
set_secret() {
    local secret_name=$1
    local description=$2
    
    echo "----------------------------------------"
    echo "Setting up: $secret_name"
    echo "Description: $description"
    echo ""
    
    # Check if secret already exists
    if gh secret list --repo $REPO | grep -q "^$secret_name"; then
        read -p "$secret_name already exists. Do you want to update it? (y/n): " update
        if [[ $update != "y" ]]; then
            echo "Skipping $secret_name"
            return
        fi
    fi
    
    echo "Please enter the value for $secret_name:"
    read -s secret_value
    echo ""
    
    if [[ -z "$secret_value" ]]; then
        echo "WARNING: Empty value provided for $secret_name. Skipping."
        return
    fi
    
    echo "$secret_value" | gh secret set $secret_name --repo $REPO
    
    if [ $? -eq 0 ]; then
        echo "✓ $secret_name configured successfully"
    else
        echo "✗ Failed to set $secret_name"
    fi
    echo ""
}

# Set up each secret
set_secret "CF_API_KEY" "CurseForge API Key for uploading releases"
set_secret "WAGO_API_TOKEN" "Wago.io API Token for uploading releases"
set_secret "WOWI_API_TOKEN" "WoWInterface API Token for uploading releases"
set_secret "DISCORD_WEBHOOK" "Discord Webhook URL for release notifications (optional)"

echo "================================================"
echo "Setup Complete!"
echo "================================================"
echo ""
echo "Current secrets in $REPO:"
gh secret list --repo $REPO
echo ""
echo "Your next release will automatically upload to:"
echo "✓ GitHub Releases"
echo "✓ CurseForge"
echo "✓ WoWInterface"
echo "✓ Wago.io"
echo "✓ Discord (if webhook configured)"
echo ""
echo "To trigger a release, create and push a version tag:"
echo "  git tag v1.0.5"
echo "  git push origin v1.0.5"
echo ""