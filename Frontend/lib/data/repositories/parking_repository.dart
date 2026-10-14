/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
import '../../core/models/parking_slot.dart';
import '../mock/mock_data.dart';

/// Parking data access.
/// Live: [FirebaseParkingRepository]. Fallback: [MockParkingRepository].
abstract class ParkingRepository {
  Future<ParkingSummary> fetchSummary();
}

class MockParkingRepository implements ParkingRepository {
  @override
  Future<ParkingSummary> fetchSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    return MockData.parkingSummary();
  }
}
