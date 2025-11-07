import 'package:flutter/material.dart';
import 'dart:math' as Math;
import '../models/station.dart';
import '../widgets/glb_model_widget.dart';
import '../utils/responsive_helper.dart';

class ARNavigationOverlay extends StatelessWidget {
  final Station? selectedStation;
  final double? distance;
  final double? bearing;
  final double screenWidth;
  final double screenHeight;

  const ARNavigationOverlay({
    super.key,
    required this.selectedStation,
    required this.distance,
    required this.bearing,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedStation == null || distance == null || bearing == null) {
      return const SizedBox.shrink();
    }

    final bool isStationInView = _isStationInView();

    return Stack(
      children: [
        // Vertical stack of spheres pointing toward destination (only show when station is NOT in view)
        if (!isStationInView) _buildVerticalSphereStack(context),
        
        // Navigation arrow at bottom center (only show when station is NOT in view)
        if (!isStationInView) _buildNavigationArrow(context),
        
        // Destination pin when station is in view
        if (isStationInView) _buildDestinationPin(context),
      ],
    );
  }

  Widget _buildVerticalSphereStack(BuildContext context) {
    // Check if station is behind the user (between 135° and 225°)
    // Don't show spheres if destination is behind
    double normalizedBearing = bearing! % 360;
    if (normalizedBearing < 0) normalizedBearing += 360;
    
    // Station is behind if bearing is between 135° and 225°
    final bool isBehind = normalizedBearing >= 135 && normalizedBearing <= 225;
    if (isBehind) {
      return const SizedBox.shrink();
    }
    
    // Base size for the smallest sphere (top)
    final double baseSize = ResponsiveHelper.getResponsiveWidth(context, 40, tabletWidth: 50, desktopWidth: 60);
    
    // Sphere sizes increasing from top to bottom (like the reference image)
    final List<double> sphereSizes = [
      baseSize * 0.6,      // Smallest (top)
      baseSize * 0.75,     // Small
      baseSize * 1.0,      // Medium
      baseSize * 1.3,      // Large
      baseSize * 1.6,      // Largest (bottom)
    ];
    
    // Spacing between spheres vertically
    final double sphereSpacing = ResponsiveHelper.getResponsiveSpacing(context, 8, tabletSpacing: 10, desktopSpacing: 12);
    
    // Calculate total height of the stack
    final double totalHeight = sphereSizes.fold<double>(0, (sum, size) => sum + size) + 
                               (sphereSizes.length - 1) * sphereSpacing;
    
    // Position at center of screen vertically, horizontally centered
    final double centerY = screenHeight * 0.5;
    final double startY = centerY - (totalHeight / 2);
    
    // Calculate horizontal direction based on arrow's pointing direction
    // Arrow rotation: ((normalizedBearing - 90) * Math.pi) / 180
    // This means: 0° bearing → arrow points up, 90° → right, 180° → down, 270° → left
    // We want to calculate the horizontal component of the arrow direction
    
    // Convert bearing to screen coordinates
    // 0° = North (up), 90° = East (right), 180° = South (down), 270° = West (left)
    // Calculate the horizontal component (left/right) of the direction
    // Use sin of the bearing angle to get horizontal component
    final double bearingRadians = (normalizedBearing * Math.pi) / 180;
    final double horizontalComponent = Math.sin(bearingRadians);
    
    // Normalize to -1.0 (left) to 1.0 (right) range
    // This directly corresponds to which direction the arrow is pointing horizontally
    final double horizontalDirection = horizontalComponent.clamp(-1.0, 1.0);
    
    // Maximum horizontal offset (as a percentage of screen width)
    // The curve should be more pronounced for destinations further left/right
    // Make the curve more pronounced (increase from 0.15 to 0.25 for better visibility)
    final double maxHorizontalOffset = screenWidth * 0.25 * horizontalDirection;
    
    // Calculate maximum width needed to prevent clipping
    final double maxSphereSize = sphereSizes.reduce(Math.max);
    final double maxHorizontalSpread = maxHorizontalOffset.abs() + maxSphereSize;
    final double containerWidth = maxHorizontalSpread * 2.5;
    
    return Positioned(
      top: startY,
      left: (screenWidth * 0.5) - (containerWidth / 2),
      child: SizedBox(
        width: containerWidth,
        height: totalHeight,
        child: Stack(
          children: sphereSizes.asMap().entries.map((entry) {
            final int index = entry.key;
            final double size = entry.value;
            
            // Calculate vertical position
            double currentY = 0;
            for (int i = 0; i < index; i++) {
              currentY += sphereSizes[i] + sphereSpacing;
            }
            currentY += sphereSizes[index] / 2;
            
            // Calculate horizontal offset based on position in stack and bearing
            // Lower spheres curve more (create arc pointing toward destination)
            // Progress from 0.0 (top) to 1.0 (bottom)
            final double progress = index / (sphereSizes.length - 1.0);
            // Use a smoother curve - cubic for more natural arc
            final double curveProgress = progress * progress * progress;
            // Apply the curve intensity and direction
            final double horizontalOffset = maxHorizontalOffset * curveProgress;
            
            return Positioned(
              left: (containerWidth / 2) - (size / 2) + horizontalOffset,
              top: currentY - (size / 2),
              child: GLBModelWidget(
                assetPath: 'assets/models/earth.glb',
                width: size,
                height: size,
                tintColor: null, // Use original model colors
                autoRotate: true,
                rotationSpeed: 0.5,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDestinationPin(BuildContext context) {
    if (selectedStation == null) return const SizedBox.shrink();
    
    final double base = Math.min(screenWidth, screenHeight);
    final double pinSize = base * 0.18; // 18% of shortest dimension
    
    // Calculate the width needed for the station name
    final double textPadding = ResponsiveHelper.getResponsiveSpacing(context, 12, tabletSpacing: 16, desktopSpacing: 20);
    final double nameFontSize = ResponsiveHelper.getResponsiveFontSize(context, 16, tabletSize: 18, desktopSize: 20);
    
    return Positioned(
      top: screenHeight * 0.38,
      left: 0,
      right: 0,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Station name above the pin
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: textPadding,
                vertical: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 8, tabletSpacing: 10, desktopSpacing: 12)),
                border: Border.all(
                  color: const Color(0xFF2E7D32),
                  width: ResponsiveHelper.getResponsiveSpacing(context, 2, tabletSpacing: 2.5, desktopSpacing: 3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                selectedStation!.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: nameFontSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8, tabletSpacing: 10, desktopSpacing: 12)),
            // Pin model
            GLBModelWidget(
              assetPath: 'assets/models/pin_loc.glb',
              width: pinSize,
              height: pinSize,
              tintColor: const Color(0xFF2E7D32),
              autoRotate: true,
              rotationSpeed: 0.5,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNavigationArrow(BuildContext context) {
    if (bearing == null) return const SizedBox.shrink();
    
    // Normalize bearing to 0-360 range
    double normalizedBearing = bearing! % 360;
    if (normalizedBearing < 0) normalizedBearing += 360;
    
    // Convert bearing to rotation angle (in radians)
    // Bearing: 0° = North (pointing up), 90° = East (pointing right), etc.
    // Flutter's rotation: 0 = pointing right, so we need to adjust
    final double rotationAngle = ((normalizedBearing - 90) * Math.pi) / 180;
    
    // Position at bottom center of screen
    final double arrowSize = ResponsiveHelper.getResponsiveWidth(context, 60, tabletWidth: 70, desktopWidth: 80);
    final double bottomOffset = ResponsiveHelper.getResponsiveSpacing(context, 100, tabletSpacing: 120, desktopSpacing: 140);
    
    return Positioned(
      bottom: bottomOffset,
      left: (screenWidth / 2) - (arrowSize / 2),
      child: Transform.rotate(
        angle: rotationAngle,
        child: GLBModelWidget(
          assetPath: 'assets/models/arrow.glb',
          width: arrowSize,
          height: arrowSize,
          tintColor: const Color(0xFF2E7D32),
          autoRotate: false,
        ),
      ),
    );
  }

  bool _isStationInView() {
    // Only show pin when very close to destination (less than 10 meters)
    return distance! < 10;
  }
}

class ARNavigationInfo extends StatelessWidget {
  final Station? selectedStation;
  final double? distance;
  final double? bearing;

  const ARNavigationInfo({
    super.key,
    required this.selectedStation,
    required this.distance,
    required this.bearing,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedStation == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25),
      left: ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25),
      right: ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25),
      child: Container(
        padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(12), tabletPadding: const EdgeInsets.all(16), desktopPadding: const EdgeInsets.all(20)),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 10, tabletSpacing: 12, desktopSpacing: 15)),
          border: Border.all(color: const Color(0xFF2E7D32), width: ResponsiveHelper.getResponsiveSpacing(context, 1, tabletSpacing: 1.5, desktopSpacing: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GLBModelWidget(
                  assetPath: 'assets/models/arrow.glb',
                  width: ResponsiveHelper.getResponsiveWidth(context, 20, tabletWidth: 24, desktopWidth: 28),
                  height: ResponsiveHelper.getResponsiveHeight(context, 20, tabletHeight: 24, desktopHeight: 28),
                  tintColor: null, // Use original model colors
                ),
                SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
                Expanded(
                  child: Text(
                    'Navigating to: ${selectedStation!.name}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14, tabletSize: 16, desktopSize: 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
            if (distance != null)
              Row(
                children: [
                  Icon(Icons.straighten, color: Colors.white70, size: ResponsiveHelper.getIconSize(context, 14, tabletSize: 16, desktopSize: 18)),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 3, tabletSpacing: 4, desktopSpacing: 5)),
                  Text(
                    'Distance: ${distance!.toStringAsFixed(0)} meters',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                    ),
                  ),
                ],
              ),
            if (bearing != null)
              Row(
                children: [
                  Icon(Icons.navigation, color: Colors.white70, size: ResponsiveHelper.getIconSize(context, 14, tabletSize: 16, desktopSize: 18)),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 3, tabletSpacing: 4, desktopSpacing: 5)),
                  Text(
                    'Direction: ${bearing!.toStringAsFixed(0)}°',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                    ),
                  ),
                ],
              ),
            if (distance != null && distance! < 20)
              Container(
                margin: EdgeInsets.only(top: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
                padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.symmetric(horizontal: 6, vertical: 3), tabletPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), desktopPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 3, tabletSpacing: 4, desktopSpacing: 5)),
                  border: Border.all(color: Colors.green, width: ResponsiveHelper.getResponsiveSpacing(context, 1, tabletSpacing: 1.5, desktopSpacing: 2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GLBModelWidget(
                      assetPath: 'assets/models/pin_loc.glb',
                      width: ResponsiveHelper.getResponsiveWidth(context, 14, tabletWidth: 16, desktopWidth: 18),
                      height: ResponsiveHelper.getResponsiveHeight(context, 14, tabletHeight: 16, desktopHeight: 18),
                      tintColor: Colors.green,
                    ),
                    SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 3, tabletSpacing: 4, desktopSpacing: 5)),
                    Text(
                      'Destination in view!',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10, tabletSize: 12, desktopSize: 14),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
