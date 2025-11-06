import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  bool _isLocationEnabled = false;
  bool _isLocationPermissionGranted = false;
  String? _locationError;

  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;
  bool get isLocationPermissionGranted => _isLocationPermissionGranted;
  String? get locationError => _locationError;

  Future<void> initializeLocation() async {
    try {
      // Check if location services are enabled
      _isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_isLocationEnabled) {
        _locationError = 'Location services are disabled. Please enable location services.';
        notifyListeners();
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationError = 'Location permissions are denied.';
          _isLocationPermissionGranted = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Location permissions are permanently denied. Please enable in settings.';
        _isLocationPermissionGranted = false;
        notifyListeners();
        return;
      }

      _isLocationPermissionGranted = true;
      _locationError = null;

      // Get current position
      await getCurrentLocation();
    } catch (e) {
      _locationError = 'Error initializing location: $e';
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    if (!_isLocationEnabled || !_isLocationPermissionGranted) {
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _locationError = null;
      notifyListeners();
    } catch (e) {
      _locationError = 'Error getting location: $e';
      notifyListeners();
    }
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    _isLocationPermissionGranted = status == PermissionStatus.granted;
    notifyListeners();
    return _isLocationPermissionGranted;
  }

  void clearError() {
    _locationError = null;
    notifyListeners();
  }
}
