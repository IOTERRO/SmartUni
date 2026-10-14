import '../../core/models/parking_slot.dart';
import '../mock/mock_data.dart';

/// Parking data access.
/// Step 1: mock. Later: Firebase Realtime DB fed by IoT sensors.
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
