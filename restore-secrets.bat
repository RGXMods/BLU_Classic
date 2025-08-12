@echo off
echo ========================================
echo Restoring GitHub Secrets from .env file
echo ========================================
echo.

REM Check if .env file exists
if not exist .env (
    echo ERROR: .env file not found!
    echo Please ensure .env file exists with your API tokens
    pause
    exit /b 1
)

echo Reading tokens from .env file...
echo.

REM Read tokens from .env file
for /f "tokens=1,2 delims==" %%a in ('findstr "^CF_API_KEY=" .env') do set CF_KEY=%%b
for /f "tokens=1,2 delims==" %%a in ('findstr "^WAGO_API_TOKEN=" .env') do set WAGO_TOKEN=%%b
for /f "tokens=1,2 delims==" %%a in ('findstr "^WOWI_API_TOKEN=" .env') do set WOWI_TOKEN=%%b

REM Set repository
set REPO=DonnieDice/BLU_Classic

echo Setting secrets for: %REPO%
echo.

REM Set CurseForge API Key
if not "%CF_KEY%"=="" (
    echo Setting CF_API_KEY...
    echo %CF_KEY% | gh secret set CF_API_KEY --repo %REPO%
    echo [OK] CF_API_KEY set
) else (
    echo [SKIP] CF_API_KEY not found in .env
)

REM Set Wago API Token
if not "%WAGO_TOKEN%"=="" (
    echo Setting WAGO_API_TOKEN...
    echo %WAGO_TOKEN% | gh secret set WAGO_API_TOKEN --repo %REPO%
    echo [OK] WAGO_API_TOKEN set
) else (
    echo [SKIP] WAGO_API_TOKEN not found in .env
)

REM Set WoWInterface API Token
if not "%WOWI_TOKEN%"=="" (
    echo Setting WOWI_API_TOKEN...
    echo %WOWI_TOKEN% | gh secret set WOWI_API_TOKEN --repo %REPO%
    echo [OK] WOWI_API_TOKEN set
) else (
    echo [SKIP] WOWI_API_TOKEN not found in .env
)

echo.
echo ========================================
echo Verification
echo ========================================
gh secret list --repo %REPO%

echo.
echo Done! Your secrets have been restored.
pause