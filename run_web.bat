@echo off
echo Starting WondaGO Map Web App...
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter is not installed or not in PATH.
    echo Please install Flutter SDK first.
    echo Visit: https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

echo Flutter found! Starting web app...
echo.

REM Install dependencies
echo Installing dependencies...
flutter pub get

echo.
echo Starting WondaGO Map in Chrome...
echo The app will open in your default browser.
echo.

REM Run the web app
flutter run -d chrome

echo.
echo Web app session ended.
pause











