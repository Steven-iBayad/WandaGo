class Station {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final bool isActive;

  const Station({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description = '',
    this.isActive = true,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'isActive': isActive,
    };
  }

  /// Gets the brief description (first line before double newline)
  String get briefDescription {
    if (description.isEmpty) return '';
    final parts = description.split('\n\n');
    return parts.isNotEmpty ? parts.first.trim() : description;
  }

  /// Gets the full description body (everything after the brief title)
  String get fullDescriptionText {
    if (description.isEmpty) return '';
    final parts = description.split('\n\n');
    if (parts.length > 1) {
      return parts.skip(1).join('\n\n').trim();
    }
    return description;
  }

  @override
  String toString() {
    return 'Station $id: $name ($latitude, $longitude)';
  }
}
