/// Author / Project Supervisor : Omar Terro
/// GitHub                      : https://github.com/IOTERRO
/// Website                     : https://omarterro.fr
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni - Smart University CityU
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ParkingScreen extends StatefulWidget {
  const ParkingScreen({super.key});

  @override
  State<ParkingScreen> createState() => _ParkingScreenState();
}

class _ParkingScreenState extends State<ParkingScreen> {

  
  final String baseUrl =
      "https:// smart-university-api.khaledothman750.workers.dev ";

  List<dynamic> parkingSlots = [];

  bool loading = true;

  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();

    loadParking();

    // Refresh every 3 seconds
    refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        loadParking();
      },
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadParking() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/parking"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          if (data is List) {
            parkingSlots = data;
          } else if (data["slots"] is List) {
            parkingSlots = data["slots"];
          }

          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Parking error: $e");

      setState(() {
        loading = false;
      });
    }
  }

  bool isOccupied(dynamic slot) {
    final value = slot["is_occupied"];

    if (value == true ||
        value == 1 ||
        value == "1" ||
        value == "true") {
      return true;
    }

    return false;
  }

  String slotName(dynamic slot, int index) {
    return slot["slot_code"]?.toString() ??
        "Slot ${index + 1}";
  }

  @override
  Widget build(BuildContext context) {
    int occupied = parkingSlots
        .where((slot) => isOccupied(slot))
        .length;

    int available =
        parkingSlots.length - occupied;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Parking"),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: loadParking,

        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )

            : ListView(
                padding: const EdgeInsets.all(20),

                children: [

                  const Icon(
                    Icons.local_parking,
                    size: 75,
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "Campus Parking",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [

                      Expanded(
                        child: _summaryCard(
                          "Available",
                          available.toString(),
                          Icons.check_circle,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _summaryCard(
                          "Occupied",
                          occupied.toString(),
                          Icons.directions_car,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Parking Slots",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (parkingSlots.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No parking data available.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  ...parkingSlots
                      .asMap()
                      .entries
                      .map(
                        (entry) {

                          final index = entry.key;
                          final slot = entry.value;

                          final occupied =
                              isOccupied(slot);

                          return Card(
                            margin:
                                const EdgeInsets.only(
                              bottom: 12,
                            ),

                            child: ListTile(

                              leading: CircleAvatar(
                                child: Icon(
                                  occupied
                                      ? Icons
                                          .directions_car
                                      : Icons
                                          .local_parking,
                                ),
                              ),

                              title: Text(
                                slotName(
                                  slot,
                                  index,
                                ),
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              subtitle: Text(
                                occupied
                                    ? "Occupied"
                                    : "Available",
                              ),

                              trailing: Icon(
                                occupied
                                    ? Icons.cancel
                                    : Icons
                                        .check_circle,
                              ),
                            ),
                          );
                        },
                      ),
                ],
              ),
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [

            Icon(
              icon,
              size: 35,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(title),
          ],
        ),
      ),
    );
  }
}