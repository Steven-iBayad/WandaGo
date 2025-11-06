import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../utils/responsive_helper.dart';
import 'qr_scanner_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize location services
    await context.read<LocationProvider>().initializeLocation();
    
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const QRScannerScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E7D32), // Forest green
              Color(0xFF4CAF50), // Light green
              Color(0xFF8BC34A), // Lime green
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Container
                      Container(
                        width: ResponsiveHelper.getResponsiveWidth(context, 150, tabletWidth: 200, desktopWidth: 250),
                        height: ResponsiveHelper.getResponsiveHeight(context, 150, tabletHeight: 200, desktopHeight: 250),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25),
                              offset: Offset(0, ResponsiveHelper.getResponsiveSpacing(context, 8, tabletSpacing: 10, desktopSpacing: 12)),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25)),
                          child: Image.asset(
                            'assets/images/WondaGO_logo.webp',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if logo is not available
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                                  ),
                                  borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25)),
                                ),
                                child: Icon(
                                  Icons.map,
                                  size: ResponsiveHelper.getIconSize(context, 60, tabletSize: 80, desktopSize: 100),
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 20, tabletSpacing: 30, desktopSpacing: 40)),
                      Text(
                        'WondaGO Map',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 24, tabletSize: 28, desktopSize: 32),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: ResponsiveHelper.getResponsiveSpacing(context, 0.8, tabletSpacing: 1.2, desktopSpacing: 1.5),
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(ResponsiveHelper.getResponsiveSpacing(context, 1.5, tabletSpacing: 2, desktopSpacing: 2.5), ResponsiveHelper.getResponsiveSpacing(context, 1.5, tabletSpacing: 2, desktopSpacing: 2.5)),
                              blurRadius: ResponsiveHelper.getResponsiveSpacing(context, 3, tabletSpacing: 4, desktopSpacing: 5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8, tabletSpacing: 10, desktopSpacing: 12)),
                      Text(
                        'AR Navigation',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16, tabletSize: 18, desktopSize: 20),
                          color: Colors.white70,
                          letterSpacing: ResponsiveHelper.getResponsiveSpacing(context, 0.3, tabletSpacing: 0.5, desktopSpacing: 0.7),
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(ResponsiveHelper.getResponsiveSpacing(context, 0.8, tabletSpacing: 1, desktopSpacing: 1.2), ResponsiveHelper.getResponsiveSpacing(context, 0.8, tabletSpacing: 1, desktopSpacing: 1.2)),
                              blurRadius: ResponsiveHelper.getResponsiveSpacing(context, 1.5, tabletSpacing: 2, desktopSpacing: 2.5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4, tabletSpacing: 5, desktopSpacing: 6)),
                      Text(
                        'Navigate with Augmented Reality',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(ResponsiveHelper.getResponsiveSpacing(context, 0.8, tabletSpacing: 1, desktopSpacing: 1.2), ResponsiveHelper.getResponsiveSpacing(context, 0.8, tabletSpacing: 1, desktopSpacing: 1.2)),
                              blurRadius: ResponsiveHelper.getResponsiveSpacing(context, 1.5, tabletSpacing: 2, desktopSpacing: 2.5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 30, tabletSpacing: 50, desktopSpacing: 60)),
                      CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: ResponsiveHelper.getResponsiveSpacing(context, 2.5, tabletSpacing: 3, desktopSpacing: 3.5),
                      ),
                      SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 15, tabletSpacing: 20, desktopSpacing: 25)),
                      Text(
                        'Initializing navigation system...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12, tabletSize: 14, desktopSize: 16),
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(ResponsiveHelper.getResponsiveSpacing(context, 0.8, tabletSpacing: 1, desktopSpacing: 1.2), ResponsiveHelper.getResponsiveSpacing(context, 0.8, tabletSpacing: 1, desktopSpacing: 1.2)),
                              blurRadius: ResponsiveHelper.getResponsiveSpacing(context, 1.5, tabletSpacing: 2, desktopSpacing: 2.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}