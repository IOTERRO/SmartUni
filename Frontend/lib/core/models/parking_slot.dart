/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
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

  /// Maps ESP / Firebase RTDB spot JSON → app model.
  factory ParkingSlot.fromFirebaseJson(String key, Map<String, dynamic> json) {
    final id = (json['spot_id'] ?? key).toString();
    final label = (json['label'] as String?)?.trim();
    final status = (json['status'] as String? ?? '').toLowerCase();
    return ParkingSlot(
      id: id,
      code: (label != null && label.isNotEmpty) ? '$id · $label' : id,
      isOccupied: status == 'occupied',
      zone: 'Lot A',
      updatedAt: DateTime.now(),
    );
  }
}

class ParkingSummary {
  final List<ParkingSlot> slots;

  const ParkingSummary(this.slots);

  int get total => slots.length;

  int get occupied => slots.where((s) => s.isOccupied).length;

  int get available => total - occupied;
}
