@echo off
echo Installing Flutter SDK for WondaGO Map AR Navigation App...
echo.

REM Check if FVM is installed
fvm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo FVM is not installed. Please install FVM first.
    echo Download from: https://fvm.app/docs/getting_started/installation
    pause
    exit /b 1
)

REM Check if Flutter is available through FVM
fvm flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo Flutter is already installed through FVM!
    fvm flutter --version
    echo.
    echo Running flutter doctor to check setup...
    fvm flutter doctor
    echo.
    echo Installing dependencies...
    fvm flutter pub get
    echo.
    echo Setup complete! You can now run the app with:
    echo   fvm flutter run -d chrome
    echo   or
    echo   fvm flutter run
    pause
    exit /b 0
)

echo Flutter not found through FVM. Installing Flutter via FVM...
echo.
echo Installing Flutter stable via FVM...
fvm install stable
echo.
echo Setting Flutter stable as project version...
fvm use stable
echo.
echo Installing dependencies...
fvm flutter pub get
echo.
echo Running flutter doctor...
fvm flutter doctor
echo.
echo Setup complete! You can now run the app with:
echo   fvm flutter run -d chrome
echo   or
echo   fvm flutter run
echo.
pause
