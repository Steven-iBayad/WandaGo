import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as Math;
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/navigation_provider.dart';
import '../providers/location_provider.dart';
import '../widgets/ar_navigation_overlay.dart';
import '../data/stations_data.dart';
import '../models/station.dart';
import '../utils/responsive_helper.dart';

class ARNavigationScreen extends StatefulWidget {
  const ARNavigationScreen({super.key});

  @override
  State<ARNavigationScreen> createState() => _ARNavigationScreenState();
}

class _ARNavigationScreenState extends State<ARNavigationScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String? _cameraError;
  bool _isStationSelectorOpen = false;
  bool _isSwitchingCamera = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLocationUpdates();
      _initializeCamera();
    });
  }

  void _startLocationUpdates() {
    final locationProvider = context.read<LocationProvider>();
    locationProvider.getLocationStream().listen((position) {
      context.read<NavigationProvider>().updateLocation(
        position.latitude,
        position.longitude,
      );
    });
  }

  Future<void> _initializeCamera({CameraLensDirection lensDirection = CameraLensDirection.back}) async {
    try {
      // Set loading state
      setState(() {
        _isCameraInitialized = false;
        _cameraError = null;
      });

      // Request camera permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        setState(() {
          _cameraError = 'Camera permission denied';
        });
        return;
      }

      // Get available cameras if not already loaded
      if (_cameras == null) {
        _cameras = await availableCameras();
        if (_cameras == null || _cameras!.isEmpty) {
          setState(() {
            _cameraError = 'No cameras available';
          });
          return;
        }
      }

      // Dispose existing controller properly
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      // Wait a bit for the camera to be fully released
      await Future.delayed(const Duration(milliseconds: 100));

      // Initialize camera controller with specified lens direction
      final selectedCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == lensDirection,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _cameraError = null;
          _isSwitchingCamera = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cameraError = 'Failed to initialize camera: $e';
          _isCameraInitialized = false;
          _isSwitchingCamera = false;
        });
      }
    }
  }

  void _toggleCamera() {
    if (_cameras == null || _cameras!.length < 2) return;
    
    final currentLensDirection = _cameraController?.description.lensDirection;
    final newLensDirection = currentLensDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    
    // Show switching state
    setState(() {
      _isCameraInitialized = false;
      _cameraError = null;
      _isSwitchingCamera = true;
    });
    
    _initializeCamera(lensDirection: newLensDirection);
  }

  void _selectStation(Station station) {
    context.read<NavigationProvider>().selectStation(station);
    setState(() {
      _isStationSelectorOpen = false;
    });
  }

  Widget _buildStationSelector() {
    final stations = StationsData.getActiveStations();
    final currentStation = context.read<NavigationProvider>().selectedStation;
    
    return _StationSelectorModal(
      stations: stations,
      currentStation: currentStation,
      onStationSelected: (station) {
        _selectStation(station);
      },
      onClose: () {
        setState(() {
          _isStationSelectorOpen = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Widget _buildWebNavigation() {
    return Consumer2<NavigationProvider, LocationProvider>(
      builder: (context, navigationProvider, locationProvider, child) {
        final selectedStation = navigationProvider.selectedStation;
        final distance = navigationProvider.distanceToStation;
        final bearing = navigationProvider.bearingToStation;

        if (selectedStation == null) {
          return const Center(
            child: Text('No station selected'),
          );
        }

        return Column(
          children: [
            // Navigation Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Navigating to: ${selectedStation.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (distance != null)
                    Text(
                      'Distance: ${distance.toStringAsFixed(0)} meters',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  if (bearing != null)
                    Text(
                      'Direction: ${bearing.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isStationSelectorOpen = true;
                      });
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('Change Station'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation Compass
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (bearing != null)
                      Transform.rotate(
                        angle: (bearing * Math.pi) / 180,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2E7D32),
                              width: 4,
                            ),
                          ),
                          child: const Icon(
                            Icons.navigation,
                            color: Color(0xFF2E7D32),
                            size: 80,
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF2E7D32),
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            selectedStation.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Text(
                              selectedStation.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Coordinates: ${selectedStation.latitude.toStringAsFixed(6)}, ${selectedStation.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileNavigation() {
    return Consumer2<NavigationProvider, LocationProvider>(
      builder: (context, navigationProvider, locationProvider, child) {
        final selectedStation = navigationProvider.selectedStation;
        final distance = navigationProvider.distanceToStation;
        final bearing = navigationProvider.bearingToStation;

        if (selectedStation == null) {
          return const Center(
            child: Text('No station selected'),
          );
        }

        return Stack(
          children: [
            // Camera Preview
            if (_isCameraInitialized && _cameraController != null)
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: CameraPreview(_cameraController!),
              )
            else
              Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_cameraError != null) ...[
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Camera Error',
                          style: TextStyle(
                            color: Colors.red[300],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _cameraError!,
                            style: TextStyle(
                              color: Colors.red[200],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _initializeCamera,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ] else ...[
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isSwitchingCamera ? 'Switching Camera...' : 'Initializing Camera...',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            
            // Multi-Arrow AR Navigation Overlay
            ARNavigationOverlay(
              selectedStation: selectedStation,
              distance: distance,
              bearing: bearing,
              screenWidth: MediaQuery.of(context).size.width,
              screenHeight: MediaQuery.of(context).size.height,
            ),
            
            // Enhanced Navigation Info Overlay
            ARNavigationInfo(
              selectedStation: selectedStation,
              distance: distance,
              bearing: bearing,
            ),

            // Instructions
            Positioned(
              bottom: ResponsiveHelper.getResponsiveSpacing(context, 200, tabletSpacing: 220, desktopSpacing: 240),
              left: 20,
              right: 20,
              child: Container(
                padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(12), tabletPadding: const EdgeInsets.all(16), desktopPadding: const EdgeInsets.all(16)),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 10, tabletSpacing: 12, desktopSpacing: 15)),
                ),
                child: Text(
                  'Follow the arrow at the bottom pointing toward your destination. When you get close, you\'ll see the 3D pin marker at the station location.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Location Error
            if (locationProvider.locationError != null)
              Positioned(
                top: 100,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          locationProvider.locationError!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          locationProvider.clearError();
                          locationProvider.getCurrentLocation();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('AR Navigation'),
            const SizedBox(width: 8),
            if (_isCameraInitialized && _cameraController != null)
              Icon(
                _cameraController!.description.lensDirection == CameraLensDirection.back
                    ? Icons.camera_rear
                    : Icons.camera_front,
                size: 20,
              ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isStationSelectorOpen = true;
              });
            },
            icon: const Icon(Icons.location_on),
            tooltip: 'Change Station',
          ),
          if (_cameras != null && _cameras!.length > 1)
            IconButton(
              onPressed: _toggleCamera,
              icon: Icon(_cameraController?.description.lensDirection == CameraLensDirection.back
                  ? Icons.camera_front
                  : Icons.camera_rear),
              tooltip: 'Switch Camera',
            ),
          IconButton(
            onPressed: () {
              context.read<NavigationProvider>().stopNavigation();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Stack(
        children: [
          kIsWeb ? _buildWebNavigation() : _buildMobileNavigation(),
          if (_isStationSelectorOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isStationSelectorOpen = false;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: GestureDetector(
                    onTap: () {}, // Prevent closing when tapping on the selector
                    child: _buildStationSelector(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StationSelectorModal extends StatefulWidget {
  final List<Station> stations;
  final Station? currentStation;
  final Function(Station) onStationSelected;
  final VoidCallback onClose;

  const _StationSelectorModal({
    required this.stations,
    required this.currentStation,
    required this.onStationSelected,
    required this.onClose,
  });

  @override
  State<_StationSelectorModal> createState() => _StationSelectorModalState();
}

class _StationSelectorModalState extends State<_StationSelectorModal> {
  late Station? _selectedStationForView;

  @override
  void initState() {
    super.initState();
    _selectedStationForView = widget.currentStation;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveHelper.getResponsiveWidth(context, MediaQuery.of(context).size.width * 0.9, tabletWidth: MediaQuery.of(context).size.width * 0.7, desktopWidth: 500),
      constraints: BoxConstraints(
        maxHeight: ResponsiveHelper.getResponsiveHeight(context, MediaQuery.of(context).size.height * 0.75, tabletHeight: MediaQuery.of(context).size.height * 0.8, desktopHeight: 600),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(16), tabletPadding: const EdgeInsets.all(20), desktopPadding: const EdgeInsets.all(24)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25)),
                topRight: Radius.circular(ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25)),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Select Station',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18, tabletSize: 20, desktopSize: 22),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(Icons.close, size: ResponsiveHelper.getIconSize(context, 24, tabletSize: 26, desktopSize: 28)),
                  color: Colors.grey[600],
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          // Dropdown for station selection
          Container(
            margin: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16, tabletSpacing: 20, desktopSpacing: 24)),
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 12, tabletSpacing: 14, desktopSpacing: 16)),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 8, tabletSpacing: 10, desktopSpacing: 12)),
            ),
            child: DropdownButton<Station>(
              value: _selectedStationForView,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, size: ResponsiveHelper.getIconSize(context, 24, tabletSize: 26, desktopSize: 28)),
              items: widget.stations.map((station) {
                return DropdownMenuItem<Station>(
                  value: station,
                  child: Text(
                    station.name,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14, tabletSize: 16, desktopSize: 18),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (Station? newStation) {
                setState(() {
                  _selectedStationForView = newStation;
                });
              },
              hint: const Text('Choose a station'),
            ),
          ),
          
          SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16, tabletSpacing: 20, desktopSpacing: 24)),
          
          // Station details
          if (_selectedStationForView != null)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16, tabletSpacing: 20, desktopSpacing: 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Station number and icon
                    Row(
                      children: [
                        Container(
                          width: ResponsiveHelper.getResponsiveWidth(context, 40, tabletWidth: 48, desktopWidth: 56),
                          height: ResponsiveHelper.getResponsiveHeight(context, 40, tabletHeight: 48, desktopHeight: 56),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 20, tabletSpacing: 24, desktopSpacing: 28)),
                          ),
                          child: Center(
                            child: Text(
                              _selectedStationForView!.id.toString(),
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18, tabletSize: 20, desktopSize: 22),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 12, tabletSpacing: 14, desktopSpacing: 16)),
                        Expanded(
                          child: Text(
                            _selectedStationForView!.name,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20, tabletSize: 22, desktopSize: 24),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12, tabletSpacing: 14, desktopSpacing: 16)),
                    
                    // Brief title
                    Text(
                      _selectedStationForView!.briefDescription,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16, tabletSize: 18, desktopSize: 20),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12, tabletSpacing: 14, desktopSpacing: 16)),
                    
                    // Full description body
                    Text(
                      _selectedStationForView!.fullDescriptionText,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14, tabletSize: 15, desktopSize: 16),
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 24, tabletSpacing: 28, desktopSpacing: 32)),
                    
                    // Select button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onStationSelected(_selectedStationForView!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.symmetric(vertical: 14), tabletPadding: const EdgeInsets.symmetric(vertical: 16), desktopPadding: const EdgeInsets.symmetric(vertical: 18)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 8, tabletSpacing: 10, desktopSpacing: 12)),
                          ),
                        ),
                        child: Text(
                          'Navigate to This Station',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16, tabletSize: 18, desktopSize: 20),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16, tabletSpacing: 20, desktopSpacing: 24)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}