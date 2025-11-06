@echo off
echo Setting up WondaGO Map AR Navigation App...
echo.

echo Installing Flutter dependencies...
fvm flutter pub get
echo.

echo Creating necessary directories...
if not exist "assets\images" mkdir "assets\images"
if not exist "assets\models" mkdir "assets\models"
if not exist "web\icons" mkdir "web\icons"
echo.

echo Setup complete! 
echo.
echo The app is now ready to use with your existing logo!
echo.
echo To run the app:
echo.
echo For Android:
echo 1. Connect your Android device or start an emulator
echo 2. Run: flutter run
echo.
echo For Web:
echo 1. Run: flutter run -d chrome
echo 2. Or: flutter run -d web-server --web-port 8080
echo.
echo Note: Make sure you have Flutter SDK installed and your device is properly configured.
echo The app will use the logo from assets/images/WondaGO_logo.webp
echo.
pause