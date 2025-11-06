# Mother's Wonderland AR Navigation App

A Flutter application that provides AR navigation for the Mother's Wonderland theme park. Users can scan QR codes from their tickets and get AR-guided directions to any of the 39 stations in the park.

## Features

- **QR Code Scanning**: Scan tickets to validate entry
- **Station Selection**: Choose from 39 different stations in the park
- **AR Navigation**: Get real-time AR arrows pointing to your selected station (Android) or compass navigation (Web)
- **GPS Integration**: Accurate location tracking and distance calculations
- **Modern UI**: Beautiful, intuitive interface with theme park branding
- **Cross-Platform**: Works on Android devices and web browsers

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio for Android development
- Chrome browser for web testing
- Camera and location permissions

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd theme_park_ar_navigation
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the setup script**
   ```bash
   # On Windows
   setup.bat
   
   # On Mac/Linux
   chmod +x setup.sh && ./setup.sh
   ```

## Running the App

### Android
```bash
flutter run
```

### Web
```bash
flutter run -d chrome
# Or for web server
flutter run -d web-server --web-port 8080
```

## Station Coordinates

The app includes 39 pre-configured stations with the following coordinates:

- Station 1: 13.967100, 121.551584
- Station 2: 13.967327, 121.551591
- Station 3: 13.967195, 121.551621
- ... (and 36 more stations)

## How to Use

1. **Launch the app** - You'll see the Mother's Wonderland splash screen
2. **Scan your ticket** - Use the camera to scan the QR code on your ticket
3. **Select a station** - Browse and search through the 39 available stations
4. **Follow navigation** - 
   - **Android**: Point your device camera to see AR arrows guiding you to your selected station
   - **Web**: Use the compass interface to navigate to your selected station

## Technical Details

### Dependencies

- `qr_code_scanner`: QR code scanning capabilities
- `qr_flutter`: QR code generation for testing
- `geolocator`: GPS location services
- `provider`: State management
- `vector_math`: 3D math calculations
- `url_launcher`: Web-specific functionality

### Architecture

- **Models**: Station data structure
- **Providers**: State management for navigation and location
- **Screens**: UI screens for QR scanning, station selection, and navigation
- **Data**: Static station data with coordinates

### Platform-Specific Features

#### Android
- Camera-based QR scanning
- AR-style navigation with overlay arrows
- GPS location tracking
- Native Android permissions

#### Web
- Web camera QR scanning
- Compass-style navigation interface
- Web-based location services
- Responsive web design

## Troubleshooting

### Common Issues

1. **QR code not scanning**: Ensure good lighting and clean camera lens
2. **Location not found**: Check location permissions and GPS settings
3. **Web camera issues**: Ensure HTTPS is enabled for camera access
4. **App crashes**: Check device compatibility and Flutter version

### Permissions Required

- Camera (for QR scanning)
- Location (for GPS navigation)
- Internet (for web functionality)

## Development

### Adding New Stations

To add new stations, edit `lib/data/stations_data.dart` and add new `Station` objects to the `stations` list.

### Customizing Navigation

- **Android**: Modify `lib/screens/ar_navigation_screen.dart` for AR functionality
- **Web**: Modify the web-specific navigation in the same file

### UI Customization

The app uses a purple theme (`#9C27B0`) that can be customized in `lib/main.dart`.

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Web
```bash
flutter build web --release
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For technical support or questions about the Mother's Wonderland AR Navigation app, please contact the development team.