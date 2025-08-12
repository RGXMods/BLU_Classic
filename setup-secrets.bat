@echo off
setlocal enabledelayedexpansion

echo ================================================
echo BLU_Classic - GitHub Secrets Setup (Windows)
echo ================================================
echo.
echo This script will help you set up the required secrets for:
echo - CurseForge uploads
echo - WoWInterface uploads
echo - Wago.io uploads
echo - Discord notifications
echo.
echo You'll need your API tokens ready. If you don't have them:
echo - CurseForge: https://authors.curseforge.com/account/api-tokens
echo - Wago.io: https://addons.wago.io/account/apikeys
echo - WoWInterface: https://www.wowinterface.com/downloads/filecpl.php?action=apitokens
echo - Discord Webhook: From your Discord server settings
echo.
pause

REM Check if gh CLI is installed
where gh >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: GitHub CLI ^(gh^) is not installed.
    echo Please install it from: https://cli.github.com/
    pause
    exit /b 1
)

REM Check if authenticated
gh auth status >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Not authenticated with GitHub CLI.
    echo Please run: gh auth login
    pause
    exit /b 1
)

set REPO=DonnieDice/BLU_Classic
echo.
echo Setting up secrets for repository: %REPO%
echo.

REM CurseForge API Key
echo ----------------------------------------
echo Setting up: CF_API_KEY
echo Description: CurseForge API Key for uploading releases
echo.
echo Please enter your CurseForge API Key:
set /p CF_KEY=
if not "!CF_KEY!"=="" (
    echo !CF_KEY! | gh secret set CF_API_KEY --repo %REPO%
    if !errorlevel! equ 0 (
        echo [OK] CF_API_KEY configured successfully
    ) else (
        echo [ERROR] Failed to set CF_API_KEY
    )
) else (
    echo [SKIP] No value provided for CF_API_KEY
)
echo.

REM Wago.io API Token
echo ----------------------------------------
echo Setting up: WAGO_API_TOKEN
echo Description: Wago.io API Token for uploading releases
echo.
echo Please enter your Wago.io API Token:
set /p WAGO_TOKEN=
if not "!WAGO_TOKEN!"=="" (
    echo !WAGO_TOKEN! | gh secret set WAGO_API_TOKEN --repo %REPO%
    if !errorlevel! equ 0 (
        echo [OK] WAGO_API_TOKEN configured successfully
    ) else (
        echo [ERROR] Failed to set WAGO_API_TOKEN
    )
) else (
    echo [SKIP] No value provided for WAGO_API_TOKEN
)
echo.

REM WoWInterface API Token
echo ----------------------------------------
echo Setting up: WOWI_API_TOKEN
echo Description: WoWInterface API Token for uploading releases
echo.
echo Please enter your WoWInterface API Token:
set /p WOWI_TOKEN=
if not "!WOWI_TOKEN!"=="" (
    echo !WOWI_TOKEN! | gh secret set WOWI_API_TOKEN --repo %REPO%
    if !errorlevel! equ 0 (
        echo [OK] WOWI_API_TOKEN configured successfully
    ) else (
        echo [ERROR] Failed to set WOWI_API_TOKEN
    )
) else (
    echo [SKIP] No value provided for WOWI_API_TOKEN
)
echo.

REM Discord Webhook (optional)
echo ----------------------------------------
echo Setting up: DISCORD_WEBHOOK ^(optional^)
echo Description: Discord Webhook URL for release notifications
echo Note: A default webhook is already configured in the workflow
echo.
echo Enter a Discord Webhook URL ^(or press Enter to skip^):
set /p DISCORD_URL=
if not "!DISCORD_URL!"=="" (
    echo !DISCORD_URL! | gh secret set DISCORD_WEBHOOK --repo %REPO%
    if !errorlevel! equ 0 (
        echo [OK] DISCORD_WEBHOOK configured successfully
    ) else (
        echo [ERROR] Failed to set DISCORD_WEBHOOK
    )
) else (
    echo [SKIP] Using default Discord webhook from workflow
)
echo.

echo ================================================
echo Setup Complete!
echo ================================================
echo.
echo Current secrets in %REPO%:
gh secret list --repo %REPO%
echo.
echo Your next release will automatically upload to:
echo - GitHub Releases
echo - CurseForge ^(if CF_API_KEY set^)
echo - WoWInterface ^(if WOWI_API_TOKEN set^)
echo - Wago.io ^(if WAGO_API_TOKEN set^)
echo - Discord notifications ^(always enabled^)
echo.
echo To trigger a release, create and push a version tag:
echo   git tag v1.0.5
echo   git push origin v1.0.5
echo.
pause