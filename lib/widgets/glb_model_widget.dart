import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'dart:io';

class GLBModelWidget extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;
  final Color? tintColor;
  final bool autoRotate;
  final double rotationSpeed;

  const GLBModelWidget({
    super.key,
    required this.assetPath,
    this.width = 100,
    this.height = 100,
    this.tintColor,
    this.autoRotate = false,
    this.rotationSpeed = 1.0,
  });

  @override
  State<GLBModelWidget> createState() => _GLBModelWidgetState();
}

class _GLBModelWidgetState extends State<GLBModelWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  Uint8List? _modelData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: Duration(seconds: (10 / widget.rotationSpeed).round()),
      vsync: this,
    );
    
    if (widget.autoRotate) {
      _rotationController.repeat();
    }
    
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      final ByteData data = await rootBundle.load(widget.assetPath);
      setState(() {
        _modelData = data.buffer.asUint8List();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red[600]),
              const SizedBox(height: 4),
              Text(
                'Model Error',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Use real 3D model rendering
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      clipBehavior: Clip.none,
      child: _buildReal3DModel(),
    );
  }

  Widget _buildReal3DModel() {
    // Use ModelViewer for actual GLB model rendering
    if (Platform.isAndroid || Platform.isIOS) {
      return ModelViewer(
        src: widget.assetPath,
        alt: '3D Model',
        ar: false, // Disable AR for overlay mode
        autoRotate: widget.autoRotate,
        autoPlay: true,
        cameraControls: false,
        backgroundColor: Colors.transparent,
        onWebViewCreated: (controller) {
          // Optional: Handle web view creation
        },
      );
    } else {
      // For web and other platforms, use enhanced 2D representation
      return _buildEnhanced3DRepresentation();
    }
  }

  Widget _buildEnhanced3DRepresentation() {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationController.value * 2 * 3.14159,
            child: CustomPaint(
              painter: Enhanced3DModelPainter(
                modelData: _modelData!,
                tintColor: widget.tintColor,
                isArrow: widget.assetPath.contains('arrow'),
                isPin: widget.assetPath.contains('pin'),
                isEarth: widget.assetPath.contains('earth'),
              ),
              size: Size(widget.width, widget.height),
            ),
        );
      },
    );
  }
}

class Enhanced3DModelPainter extends CustomPainter {
  final Uint8List modelData;
  final Color? tintColor;
  final bool isArrow;
  final bool isPin;
  final bool isEarth;

  Enhanced3DModelPainter({
    required this.modelData,
    this.tintColor,
    this.isArrow = false,
    this.isPin = false,
    this.isEarth = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    
    if (isArrow) {
      _draw3DArrow(canvas, center, radius);
    } else if (isPin) {
      _draw3DPin(canvas, center, radius);
    } else if (isEarth) {
      _draw3DSphere(canvas, center, radius);
    } else {
      _draw3DGeneric(canvas, center, radius);
    }
  }

  void _draw3DArrow(Canvas canvas, Offset center, double radius) {
    final color = tintColor ?? const Color(0xFF2E7D32);
    
    // Create gradient for 3D effect
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.7),
        color.withOpacity(0.5),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    // Draw 3D arrow with depth
    final arrowPath = Path();
    final arrowSize = radius * 0.8;
    
    // Arrow head (pointing up)
    arrowPath.moveTo(center.dx, center.dy - arrowSize);
    arrowPath.lineTo(center.dx - arrowSize * 0.4, center.dy - arrowSize * 0.2);
    arrowPath.lineTo(center.dx - arrowSize * 0.2, center.dy + arrowSize * 0.2);
    arrowPath.lineTo(center.dx - arrowSize * 0.1, center.dy + arrowSize * 0.2);
    arrowPath.lineTo(center.dx - arrowSize * 0.1, center.dy + arrowSize * 0.6);
    arrowPath.lineTo(center.dx + arrowSize * 0.1, center.dy + arrowSize * 0.6);
    arrowPath.lineTo(center.dx + arrowSize * 0.1, center.dy + arrowSize * 0.2);
    arrowPath.lineTo(center.dx + arrowSize * 0.2, center.dy + arrowSize * 0.2);
    arrowPath.lineTo(center.dx + arrowSize * 0.4, center.dy - arrowSize * 0.2);
    arrowPath.close();
    
    canvas.drawPath(arrowPath, paint);
    
    // Add highlight for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final highlightPath = Path();
    highlightPath.moveTo(center.dx, center.dy - arrowSize);
    highlightPath.lineTo(center.dx - arrowSize * 0.2, center.dy - arrowSize * 0.1);
    highlightPath.lineTo(center.dx - arrowSize * 0.1, center.dy + arrowSize * 0.1);
    highlightPath.lineTo(center.dx, center.dy + arrowSize * 0.1);
    highlightPath.close();
    
    canvas.drawPath(highlightPath, highlightPaint);
    
    // Add shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final shadowPath = Path();
    shadowPath.addPath(arrowPath, const Offset(2, 2));
    canvas.drawPath(shadowPath, shadowPaint);
  }

  void _draw3DPin(Canvas canvas, Offset center, double radius) {
    final color = tintColor ?? const Color(0xFF2E7D32);
    
    // Create gradient for 3D effect
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.7),
        color.withOpacity(0.5),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    // Draw pin head (circle)
    canvas.drawCircle(center, radius * 0.6, paint);
    
    // Draw pin point (triangle)
    final pinPath = Path();
    pinPath.moveTo(center.dx, center.dy + radius * 0.6);
    pinPath.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.9);
    pinPath.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.9);
    pinPath.close();
    
    canvas.drawPath(pinPath, paint);
    
    // Add highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx - radius * 0.2, center.dy - radius * 0.2), 
      radius * 0.2, 
      highlightPaint
    );
    
    // Add shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(center.dx + 2, center.dy + 2), radius * 0.6, shadowPaint);
  }

  void _draw3DSphere(Canvas canvas, Offset center, double radius) {
    // Use earth-like blue color as fallback, or the provided tint
    final color = tintColor ?? const Color(0xFF2196F3); // Blue earth-like default
    
    // Create radial gradient for 3D sphere effect
    final gradient = RadialGradient(
      center: Alignment(-0.3, -0.3), // Offset for highlight effect
      colors: [
        color.withOpacity(1.0),      // Bright center
        color.withOpacity(0.9),       // Slightly dimmer
        color.withOpacity(0.8),       // Mid tone
        color.withOpacity(0.6),       // Outer edge
        color.withOpacity(0.4),       // Shadow edge
      ],
      stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    // Draw the main sphere
    canvas.drawCircle(center, radius * 0.45, paint);
    
    // Add a bright highlight on top-left for 3D effect
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx - radius * 0.15, center.dy - radius * 0.15),
      radius * 0.15,
      highlightPaint,
    );
    
    // Add subtle shadow on bottom-right
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(center.dx + radius * 0.1, center.dy + radius * 0.1),
      radius * 0.45,
      shadowPaint,
    );
    
    // Add an outer glow ring for depth
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(center, radius * 0.45, glowPaint);
  }

  void _draw3DGeneric(Canvas canvas, Offset center, double radius) {
    final color = tintColor ?? Colors.blue;
    
    // Create gradient for 3D effect
    final gradient = RadialGradient(
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.7),
        color.withOpacity(0.5),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
    
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    // Draw 3D cube representation
    final cubeSize = radius * 0.6;
    final offset = cubeSize * 0.3;
    
    // Front face
    canvas.drawRect(
      Rect.fromCenter(center: center, width: cubeSize, height: cubeSize),
      paint,
    );
    
    // Top face
    final topPath = Path();
    topPath.moveTo(center.dx - cubeSize/2, center.dy - cubeSize/2);
    topPath.lineTo(center.dx - cubeSize/2 + offset, center.dy - cubeSize/2 - offset);
    topPath.lineTo(center.dx + cubeSize/2 + offset, center.dy - cubeSize/2 - offset);
    topPath.lineTo(center.dx + cubeSize/2, center.dy - cubeSize/2);
    topPath.close();
    
    final topPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(topPath, topPaint);
    
    // Right face
    final rightPath = Path();
    rightPath.moveTo(center.dx + cubeSize/2, center.dy - cubeSize/2);
    rightPath.lineTo(center.dx + cubeSize/2 + offset, center.dy - cubeSize/2 - offset);
    rightPath.lineTo(center.dx + cubeSize/2 + offset, center.dy + cubeSize/2 - offset);
    rightPath.lineTo(center.dx + cubeSize/2, center.dy + cubeSize/2);
    rightPath.close();
    
    final rightPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(rightPath, rightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Keep the old painter for fallback
class GLBModelPainter extends CustomPainter {
  final Uint8List modelData;
  final Color? tintColor;

  GLBModelPainter({
    required this.modelData,
    this.tintColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tintColor ?? Colors.blue
      ..style = PaintingStyle.fill;

    // Simple placeholder rendering - in a real implementation,
    // you would parse the GLB data and render the 3D model
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;
    
    // Draw a simple representation of the model
    canvas.drawCircle(center, radius, paint);
    
    // Draw an arrow shape to represent navigation
    final path = Path();
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - radius * 0.6, center.dy + radius * 0.3);
    path.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx - radius * 0.3, center.dy + radius);
    path.lineTo(center.dx + radius * 0.3, center.dy + radius);
    path.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx + radius * 0.6, center.dy + radius * 0.3);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add some visual indication that this is a 3D model
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'AR',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

