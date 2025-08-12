# PowerShell script to set GitHub secrets for BLU_Classic
# This will prompt for tokens and set them automatically

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Setting up GitHub Secrets for BLU_Classic" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Check if gh CLI is available
try {
    gh --version | Out-Null
} catch {
    Write-Host "ERROR: GitHub CLI (gh) is not installed." -ForegroundColor Red
    Write-Host "Please install from: https://cli.github.com/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check authentication
$authCheck = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Not authenticated with GitHub CLI." -ForegroundColor Red
    Write-Host "Please run: gh auth login" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

$repo = "DonnieDice/BLU_Classic"

Write-Host "Setting secrets for repository: $repo" -ForegroundColor Green
Write-Host ""
Write-Host "You need to enter the SAME tokens you use in your other addons" -ForegroundColor Yellow
Write-Host "(BLU, SimpleQuestPlates, FFLU, etc.)" -ForegroundColor Yellow
Write-Host ""

# Function to set a secret
function Set-GitHubSecret {
    param(
        [string]$SecretName,
        [string]$Description,
        [string]$Platform
    )
    
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host "$SecretName - $Description" -ForegroundColor Cyan
    Write-Host "Get this from: $Platform" -ForegroundColor Gray
    Write-Host ""
    
    $secureToken = Read-Host "Enter $SecretName" -AsSecureString
    
    if ($secureToken.Length -eq 0) {
        Write-Host "Skipped: $SecretName (no value provided)" -ForegroundColor Yellow
        return
    }
    
    # Convert SecureString to plain text for gh CLI
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken)
    $token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    
    # Set the secret
    $token | gh secret set $SecretName --repo $repo
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ $SecretName set successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to set $SecretName" -ForegroundColor Red
    }
    
    # Clear the token from memory
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    Write-Host ""
}

# Set each secret
Set-GitHubSecret -SecretName "CF_API_KEY" `
    -Description "CurseForge API Key" `
    -Platform "https://authors.curseforge.com/account/api-tokens"

Set-GitHubSecret -SecretName "WAGO_API_TOKEN" `
    -Description "Wago.io API Token" `
    -Platform "https://addons.wago.io/account/apikeys"

Set-GitHubSecret -SecretName "WOWI_API_TOKEN" `
    -Description "WoWInterface API Token" `
    -Platform "https://www.wowinterface.com/downloads/filecpl.php?action=apitokens"

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Verification" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Show configured secrets
$secrets = gh secret list --repo $repo
if ($secrets) {
    Write-Host "Configured secrets:" -ForegroundColor Green
    Write-Host $secrets
} else {
    Write-Host "No secrets configured" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your next release will automatically upload to:" -ForegroundColor Green
Write-Host "✓ GitHub Releases (always)" -ForegroundColor Green
Write-Host "✓ CurseForge (if CF_API_KEY set)" -ForegroundColor Green
Write-Host "✓ Wago.io (if WAGO_API_TOKEN set)" -ForegroundColor Green
Write-Host "✓ WoWInterface (if WOWI_API_TOKEN set)" -ForegroundColor Green
Write-Host "✓ Discord notifications (always)" -ForegroundColor Green
Write-Host ""
Write-Host "To create a release:" -ForegroundColor Yellow
Write-Host "  git tag v1.0.5" -ForegroundColor White
Write-Host "  git push origin v1.0.5" -ForegroundColor White
Write-Host ""
Read-Host "Press Enter to exit"