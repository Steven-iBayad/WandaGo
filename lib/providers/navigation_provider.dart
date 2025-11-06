import 'package:flutter/material.dart';
import 'dart:math' as Math;
import '../models/station.dart';

class NavigationProvider extends ChangeNotifier {
  Station? _selectedStation;
  bool _isNavigating = false;
  double? _currentLatitude;
  double? _currentLongitude;
  double? _distanceToStation;
  double? _bearingToStation;

  Station? get selectedStation => _selectedStation;
  bool get isNavigating => _isNavigating;
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;
  double? get distanceToStation => _distanceToStation;
  double? get bearingToStation => _bearingToStation;

  void selectStation(Station station) {
    _selectedStation = station;
    _isNavigating = true;
    // If we already have a current location, immediately recalculate
    // distance and bearing so UI updates right after selection.
    if (_currentLatitude != null && _currentLongitude != null) {
      _calculateDistanceAndBearing();
    }
    notifyListeners();
  }

  void stopNavigation() {
    _isNavigating = false;
    _selectedStation = null;
    _distanceToStation = null;
    _bearingToStation = null;
    notifyListeners();
  }

  void updateLocation(double latitude, double longitude) {
    _currentLatitude = latitude;
    _currentLongitude = longitude;
    
    if (_selectedStation != null) {
      _calculateDistanceAndBearing();
    }
    notifyListeners();
  }

  void _calculateDistanceAndBearing() {
    if (_currentLatitude == null || _currentLongitude == null || _selectedStation == null) {
      return;
    }

    _distanceToStation = _calculateDistance(
      _currentLatitude!,
      _currentLongitude!,
      _selectedStation!.latitude,
      _selectedStation!.longitude,
    );

    _bearingToStation = _calculateBearing(
      _currentLatitude!,
      _currentLongitude!,
      _selectedStation!.latitude,
      _selectedStation!.longitude,
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_degreesToRadians(lat1)) * Math.cos(_degreesToRadians(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    final double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double lat1Rad = _degreesToRadians(lat1);
    final double lat2Rad = _degreesToRadians(lat2);
    
    final double y = Math.sin(dLon) * Math.cos(lat2Rad);
    final double x = Math.cos(lat1Rad) * Math.sin(lat2Rad) -
        Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(dLon);
    
    double bearing = Math.atan2(y, x);
    bearing = _radiansToDegrees(bearing);
    bearing = (bearing + 360) % 360;
    
    return bearing;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (Math.pi / 180);
  }

  double _radiansToDegrees(double radians) {
    return radians * (180 / Math.pi);
  }
}
