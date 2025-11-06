import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/responsive_helper.dart';
import 'station_selection_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? controller;
  bool _isScanning = true;
  CameraFacing _cameraFacing = CameraFacing.back;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      facing: _cameraFacing, // Use rear camera for navigation
    );
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        _showPermissionDialog();
      }
    } catch (e) {
      // On web, permissions might not be available
      print('Permission request failed: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'This app needs camera access to scan QR codes from your WondaGO Map ticket. Please grant camera permission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // On web, we can't open app settings, so just continue
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isScanning && capture.barcodes.isNotEmpty) {
      final barcode = capture.barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
        });
        _processQRCode(barcode.rawValue!);
      }
    }
  }

  void _processQRCode(String qrData) {
    // Validate the QR code from the theme park ticket
    // In a real app, you would validate this with your backend system
    if (qrData.isNotEmpty && _isValidTicket(qrData)) {
      _showTicketValidDialog();
    } else {
      _showInvalidTicketDialog();
    }
  }

  bool _isValidTicket(String qrData) {
    // Basic validation - in production, this would check against your database
    // For now, accept any non-empty QR code as valid
    return qrData.isNotEmpty;
  }

  void _showTicketValidDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 10),
            const Text('Welcome!'),
          ],
        ),
        content: const Text(
          'Your WondaGO Map ticket has been validated successfully! You can now select a station to navigate to using AR.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const StationSelectionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Navigation'),
          ),
        ],
      ),
    );
  }

  void _showInvalidTicketDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            const SizedBox(width: 10),
            const Text('Invalid Ticket'),
          ],
        ),
        content: const Text(
          'The QR code scanned is not a valid WondaGO Map ticket. Please scan a valid ticket to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isScanning = true;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _resumeScanning() {
    setState(() {
      _isScanning = true;
    });
    controller?.start();
  }

  void _toggleCamera() {
    setState(() {
      _cameraFacing = _cameraFacing == CameraFacing.back 
          ? CameraFacing.front 
          : CameraFacing.back;
      _isScanning = false; // Stop scanning during switch
    });
    
    // Dispose old controller
    controller?.dispose();
    
    // Create new controller with new facing
    controller = MobileScannerController(facing: _cameraFacing);
    
    // Resume scanning after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
        controller?.start();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Scan Your Ticket'),
            const SizedBox(width: 8),
            Icon(
              _cameraFacing == CameraFacing.back 
                  ? Icons.camera_rear 
                  : Icons.camera_front,
              size: 20,
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleCamera,
            icon: Icon(_cameraFacing == CameraFacing.back 
                ? Icons.camera_front 
                : Icons.camera_rear),
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(16), tabletPadding: const EdgeInsets.all(20), desktopPadding: const EdgeInsets.all(24)),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Welcome to WondaGO Map!',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18, tabletSize: 20, desktopSize: 24),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
                Text(
                  'Scan your ticket QR code to begin your AR navigation experience',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // QR Scanner
          Expanded(
            flex: 4,
            child: MobileScanner(
              controller: controller,
              onDetect: _onDetect,
            ),
          ),
          
          // Instructions
          Expanded(
            flex: 1,
            child: Container(
              padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(16), tabletPadding: const EdgeInsets.all(20), desktopPadding: const EdgeInsets.all(24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Position your ticket\'s QR code within the frame above\n(Using rear camera for better scanning)',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14, tabletSize: 16, desktopSize: 18),
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2E7D32),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25)),
                  ResponsiveHelper.isMobile(context) 
                    ? Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _toggleCamera,
                              icon: Icon(_cameraFacing == CameraFacing.back 
                                  ? Icons.camera_front 
                                  : Icons.camera_rear),
                              label: Text(_cameraFacing == CameraFacing.back 
                                  ? 'Front Cam' 
                                  : 'Rear Cam'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.symmetric(vertical: 12), tabletPadding: const EdgeInsets.symmetric(vertical: 14), desktopPadding: const EdgeInsets.symmetric(vertical: 16)),
                              ),
                            ),
                          ),
                          if (!_isScanning) ...[
                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 10, tabletSpacing: 12, desktopSpacing: 14)),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _resumeScanning,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Scan Again'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                  padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.symmetric(vertical: 12), tabletPadding: const EdgeInsets.symmetric(vertical: 14), desktopPadding: const EdgeInsets.symmetric(vertical: 16)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _toggleCamera,
                            icon: Icon(_cameraFacing == CameraFacing.back 
                                ? Icons.camera_front 
                                : Icons.camera_rear),
                            label: Text(_cameraFacing == CameraFacing.back 
                                ? 'Front Cam' 
                                : 'Rear Cam'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.symmetric(horizontal: 16, vertical: 12), tabletPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), desktopPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                            ),
                          ),
                          if (!_isScanning)
                            ElevatedButton.icon(
                              onPressed: _resumeScanning,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Scan Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                foregroundColor: Colors.white,
                                padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.symmetric(horizontal: 16, vertical: 12), tabletPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), desktopPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                              ),
                            ),
                        ],
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}