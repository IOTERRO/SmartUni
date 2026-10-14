class ParkingSlot {
  final String id;
  final String code;
  final bool isOccupied;
  final String? zone;
  final DateTime? updatedAt;

  const ParkingSlot({
    required this.id,
    required this.code,
    required this.isOccupied,
    this.zone,
    this.updatedAt,
  });
}

class ParkingSummary {
  final List<ParkingSlot> slots;

  const ParkingSummary(this.slots);

  int get total => slots.length;

  int get occupied => slots.where((s) => s.isOccupied).length;

  int get available => total - occupied;
}
