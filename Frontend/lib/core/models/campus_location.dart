class CampusLocation {
  final String id;
  final String name;
  final String type;
  final int floor;
  final String? building;
  final String? description;

  const CampusLocation({
    required this.id,
    required this.name,
    required this.type,
    this.floor = 0,
    this.building,
    this.description,
  });

  /// Maps Navigation Worker `mapLocation` JSON → app model.
  factory CampusLocation.fromWorkerJson(Map<String, dynamic> json) {
    return CampusLocation(
      id: json['id'].toString(),
      name: (json['name'] as String? ?? '').trim(),
      type: (json['type'] as String? ?? 'building').trim(),
      floor: (json['floor'] as num?)?.toInt() ?? 0,
      building: json['code'] as String?,
      description: json['description'] as String?,
    );
  }
}

class NavigationRoutePreview {
  final List<CampusLocation> path;
  final double totalDistanceMeters;

  const NavigationRoutePreview({
    required this.path,
    required this.totalDistanceMeters,
  });
}
