# BLU_Classic - Automated Release Setup

This guide helps you configure automated releases to CurseForge, WoWInterface, and Wago.io.

## Quick Setup (Windows)

1. Run the setup script:
   ```cmd
   setup-secrets.bat
   ```

2. Enter your API tokens when prompted

3. Done! Your next tag will automatically release to all platforms.

## Quick Setup (Mac/Linux)

1. Make the script executable:
   ```bash
   chmod +x setup-secrets.sh
   ```

2. Run the setup script:
   ```bash
   ./setup-secrets.sh
   ```

3. Enter your API tokens when prompted

4. Done! Your next tag will automatically release to all platforms.

## Manual Setup

If you prefer to set up secrets manually:

### 1. Get Your API Tokens

- **CurseForge API Key**: https://authors.curseforge.com/account/api-tokens
- **Wago.io API Token**: https://addons.wago.io/account/apikeys
- **WoWInterface API Token**: https://www.wowinterface.com/downloads/filecpl.php?action=apitokens

### 2. Set GitHub Secrets

#### Option A: Command Line
```bash
# Set each secret (you'll be prompted for the value)
gh secret set CF_API_KEY --repo DonnieDice/BLU_Classic
gh secret set WAGO_API_TOKEN --repo DonnieDice/BLU_Classic
gh secret set WOWI_API_TOKEN --repo DonnieDice/BLU_Classic
```

#### Option B: GitHub Web Interface
1. Go to: https://github.com/DonnieDice/BLU_Classic/settings/secrets/actions
2. Click "New repository secret"
3. Add each secret:
   - Name: `CF_API_KEY`, Value: Your CurseForge API key
   - Name: `WAGO_API_TOKEN`, Value: Your Wago.io token
   - Name: `WOWI_API_TOKEN`, Value: Your WoWInterface token

## Creating a Release

Once secrets are configured, releases are fully automated:

```bash
# Update version in TOC file first
# Then create and push a tag:
git add .
git commit -m "chore(release): update to v1.0.5"
git tag v1.0.5
git push origin main
git push origin v1.0.5
```

The GitHub Actions workflow will automatically:
- ✅ Package the addon
- ✅ Create a GitHub release
- ✅ Upload to CurseForge
- ✅ Upload to WoWInterface
- ✅ Upload to Wago.io
- ✅ Send Discord notification

## Verifying Your Setup

Check if secrets are configured:
```bash
gh secret list --repo DonnieDice/BLU_Classic
```

You should see:
- CF_API_KEY
- WAGO_API_TOKEN
- WOWI_API_TOKEN
- DISCORD_WEBHOOK (optional)

## Troubleshooting

### Uploads not working?
- Check workflow runs: https://github.com/DonnieDice/BLU_Classic/actions
- Verify secrets are set: `gh secret list --repo DonnieDice/BLU_Classic`
- Ensure project IDs in `.toc` file are correct

### Project IDs
The addon's `.toc` file contains the project IDs:
- `X-Curse-Project-ID: 1114093`
- `X-Wago-ID: qGYM2MGg`
- `X-WoWI-ID: 26945`

These are already configured and shouldn't need changes.

## Discord Notifications

Discord notifications work automatically. The webhook is configured in the workflow, but you can override it by setting the `DISCORD_WEBHOOK` secret.