@echo off
echo Building WondaGO Map APK...
echo.

REM Check if FVM is installed
fvm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo FVM is not installed or not in PATH.
    echo Please install FVM first: https://fvm.app/docs/getting_started/installation
    pause
    exit /b 1
)

REM Check if Flutter is available through FVM
fvm flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter not found through FVM.
    echo Please run: fvm install stable
    pause
    exit /b 1
)

echo FVM Flutter found! Starting APK build...
echo.

REM Clean previous builds
echo Cleaning previous builds...
fvm flutter clean

REM Get dependencies
echo Getting dependencies...
fvm flutter pub get

REM Build APK
echo Building APK...
fvm flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ✅ APK build successful!
    echo APK location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo You can now install this APK on your Android device.
) else (
    echo.
    echo ❌ APK build failed!
    echo Please check the error messages above.
)

echo.
pause

