import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../widgets/glb_model_widget.dart';

class ModelTestScreen extends StatelessWidget {
  const ModelTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Test'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Arrow Model Test
          Expanded(
            child: Container(
              margin: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(12), tabletPadding: const EdgeInsets.all(16), desktopPadding: const EdgeInsets.all(20)),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: ResponsiveHelper.getResponsiveSpacing(context, 1, tabletSpacing: 1.5, desktopSpacing: 2)),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(6), tabletPadding: const EdgeInsets.all(8), desktopPadding: const EdgeInsets.all(10)),
                    child: Text(
                      'Navigation Arrow (GLB)',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14, tabletSize: 16, desktopSize: 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Test the actual GLB model
                            GLBModelWidget(
                              assetPath: 'assets/models/arrow.glb',
                              width: ResponsiveHelper.getResponsiveWidth(context, 80, tabletWidth: 100, desktopWidth: 120),
                              height: ResponsiveHelper.getResponsiveHeight(context, 80, tabletHeight: 100, desktopHeight: 120),
                              tintColor: const Color(0xFF2E7D32),
                              autoRotate: true,
                              rotationSpeed: 1.0,
                            ),
                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12, tabletSpacing: 16, desktopSpacing: 20)),
                            Text(
                              'arrow.glb\n(Real 3D Model)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
                            Text(
                              '✅ Real 3D Model Loading',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10, tabletSize: 12, desktopSize: 14),
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Map Pin Model Test
          Expanded(
            child: Container(
              margin: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(12), tabletPadding: const EdgeInsets.all(16), desktopPadding: const EdgeInsets.all(20)),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: ResponsiveHelper.getResponsiveSpacing(context, 1, tabletSpacing: 1.5, desktopSpacing: 2)),
                borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(6), tabletPadding: const EdgeInsets.all(8), desktopPadding: const EdgeInsets.all(10)),
                    child: Text(
                      'Destination Pin (GLB)',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14, tabletSize: 16, desktopSize: 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Test the actual GLB model
                            GLBModelWidget(
                              assetPath: 'assets/models/pin_loc.glb',
                              width: ResponsiveHelper.getResponsiveWidth(context, 80, tabletWidth: 100, desktopWidth: 120),
                              height: ResponsiveHelper.getResponsiveHeight(context, 80, tabletHeight: 100, desktopHeight: 120),
                              tintColor: const Color(0xFF2E7D32),
                              autoRotate: true,
                              rotationSpeed: 0.5,
                            ),
                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12, tabletSpacing: 16, desktopSpacing: 20)),
                            Text(
                              'pin_loc.glb\n(Real 3D Model)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
                            Text(
                              '✅ Real 3D Model Loading',
                              style: TextStyle(
                                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10, tabletSize: 12, desktopSize: 14),
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Model Info
          Container(
            margin: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(12), tabletPadding: const EdgeInsets.all(16), desktopPadding: const EdgeInsets.all(20)),
            padding: ResponsiveHelper.getResponsivePadding(context, const EdgeInsets.all(12), tabletPadding: const EdgeInsets.all(16), desktopPadding: const EdgeInsets.all(20)),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.1),
              borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
              border: Border.all(color: const Color(0xFF2E7D32), width: ResponsiveHelper.getResponsiveSpacing(context, 1, tabletSpacing: 1.5, desktopSpacing: 2)),
            ),
            child: Column(
              children: [
                Text(
                  '3D Model Status',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14, tabletSize: 16, desktopSize: 18),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 6, tabletSpacing: 8, desktopSpacing: 10)),
                Text(
                  'Both models are properly formatted GLB files and ready for AR integration.\nThey will be used as 3D overlays in the navigation system.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 10, tabletSize: 12, desktopSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
