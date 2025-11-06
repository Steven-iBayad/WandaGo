# 3D Arrow Model Instructions

## Where to Place Your 3D Arrow Assets:

### Directory: `assets/models/`

### Recommended Files:
- `arrow.glb` - Main 3D arrow model (GLB format)
- `arrow_red.glb` - Red arrow variant
- `arrow_green.glb` - Green arrow variant
- `arrow_blue.glb` - Blue arrow variant

### Model Specifications:
- **Format**: GLB (recommended) or GLTF
- **Size**: Keep under 1MB for mobile performance
- **Scale**: Design for 1 unit = 1 meter
- **Orientation**: Arrow should point forward (positive Z-axis)
- **Materials**: Use PBR materials for realistic lighting

### Creating Your Arrow Model:

#### Option 1: Download Free Models
- Visit: https://sketchfab.com/3d-models?q=arrow
- Download GLB format
- Place in `assets/models/`

#### Option 2: Create Simple Arrow
- Use Blender (free)
- Create cone + cylinder
- Export as GLB
- Place in `assets/models/`

#### Option 3: Use Online Tools
- https://gltf.report/ - GLB converter
- https://gltf-viewer.donmccurdy.com/ - Preview models

### Example Arrow Model Structure:
```
assets/models/
├── arrow.glb              # Default arrow
├── arrow_navigation.glb    # Navigation arrow
├── arrow_destination.glb   # Destination marker
└── arrow_waypoint.glb     # Waypoint indicator
```

### Integration Code Example:
```dart
// In your AR navigation screen
Widget _build3DArrow() {
  return ModelViewer(
    src: 'assets/models/arrow.glb',
    autoRotate: true,
    cameraControls: false,
    backgroundColor: Colors.transparent,
  );
}
```

### Performance Tips:
- Keep models under 1000 polygons
- Use compressed textures
- Optimize for mobile GPUs
- Test on different devices

