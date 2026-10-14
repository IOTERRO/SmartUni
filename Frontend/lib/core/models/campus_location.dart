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
}

class NavigationRoutePreview {
  final List<CampusLocation> path;
  final double totalDistanceMeters;

  const NavigationRoutePreview({
    required this.path,
    required this.totalDistanceMeters,
  });
}
