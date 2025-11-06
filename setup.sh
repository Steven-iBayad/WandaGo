#!/bin/bash

echo "Setting up Mother's Wonderland AR Navigation App..."
echo

echo "Installing Flutter dependencies..."
flutter pub get
echo

echo "Creating necessary directories..."
mkdir -p assets/images
mkdir -p assets/models
mkdir -p web/icons
echo

echo "Setup complete!"
echo
echo "The app is now ready to use with your existing logo!"
echo
echo "To run the app:"
echo
echo "For Android:"
echo "1. Connect your Android device or start an emulator"
echo "2. Run: flutter run"
echo
echo "For Web:"
echo "1. Run: flutter run -d chrome"
echo "2. Or: flutter run -d web-server --web-port 8080"
echo
echo "Note: Make sure you have Flutter SDK installed and your device is properly configured."
echo "The app will use the logo from assets/images/Mother's Wonderland.webp"
echo