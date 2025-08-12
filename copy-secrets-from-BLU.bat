@echo off
echo ========================================================
echo Copying Secrets from BLU addon to BLU_Classic
echo ========================================================
echo.
echo This script will help you copy the same API tokens
echo from your BLU addon repository to BLU_Classic.
echo.
echo You'll need to know your API token values.
echo These are the same tokens used in your other addons:
echo - BLU
echo - SimpleQuestPlates  
echo - Remove_Nameplate_Debuffs
echo - FFLU
echo.
echo If you don't remember them, you can:
echo 1. Check your password manager
echo 2. Check your local notes/files
echo 3. Generate new ones from the platforms
echo.
pause

REM Quick check that gh is available
where gh >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: GitHub CLI not found. Please install from https://cli.github.com/
    pause
    exit /b 1
)

echo.
echo Please enter your API tokens (same as in BLU addon):
echo.

REM CurseForge
echo ----------------------------------------
echo CURSEFORGE API KEY
echo (From https://authors.curseforge.com/account/api-tokens)
set /p CF_KEY=Enter CF_API_KEY: 
if not "%CF_KEY%"=="" (
    echo %CF_KEY% | gh secret set CF_API_KEY --repo DonnieDice/BLU_Classic
    echo [Set] CF_API_KEY
) else (
    echo [Skipped] CF_API_KEY
)

echo.
echo ----------------------------------------
echo WAGO.IO API TOKEN
echo (From https://addons.wago.io/account/apikeys)
set /p WAGO_TOKEN=Enter WAGO_API_TOKEN: 
if not "%WAGO_TOKEN%"=="" (
    echo %WAGO_TOKEN% | gh secret set WAGO_API_TOKEN --repo DonnieDice/BLU_Classic
    echo [Set] WAGO_API_TOKEN
) else (
    echo [Skipped] WAGO_API_TOKEN
)

echo.
echo ----------------------------------------
echo WOWINTERFACE API TOKEN  
echo (From https://www.wowinterface.com/downloads/filecpl.php?action=apitokens)
set /p WOWI_TOKEN=Enter WOWI_API_TOKEN: 
if not "%WOWI_TOKEN%"=="" (
    echo %WOWI_TOKEN% | gh secret set WOWI_API_TOKEN --repo DonnieDice/BLU_Classic
    echo [Set] WOWI_API_TOKEN
) else (
    echo [Skipped] WOWI_API_TOKEN
)

echo.
echo ========================================================
echo Verifying secrets are set...
echo ========================================================
gh secret list --repo DonnieDice/BLU_Classic

echo.
echo ========================================================  
echo Setup complete!
echo ========================================================
echo.
echo Your next tag will automatically upload to:
echo - GitHub (always)
echo - CurseForge (if CF_API_KEY was set)
echo - Wago.io (if WAGO_API_TOKEN was set)
echo - WoWInterface (if WOWI_API_TOKEN was set)
echo.
echo To test, create a new tag:
echo   git tag v1.0.5
echo   git push origin v1.0.5
echo.
pause