/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
import 'package:flutter/material.dart';
import 'dart:convert';
import 'services.dart'; 


class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
    

  final String baseUrl = "https://smart-university-api.khaledothman750.workers.dev";  
  List<dynamic> locations = [];
  String? selectedFrom;
  String? selectedTo;
  List<dynamic> path = [];
  bool isLoading = false;
  String? distance;

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final response = await ApiService.get('/api/locations');
      if (response.statusCode == 200) {
        setState(() {
          locations = jsonDecode(response.body);
        });
      } else {
        print("Failed to load locations: ${response.body}");
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }

  Future<void> findRoute() async {
    if (selectedFrom == null || selectedTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and destination')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await ApiService.get(
        '/api/navigation?from=$selectedFrom&to=$selectedTo',
      );

      print("NAV STATUS: ${response.statusCode}");
      print("NAV BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          path = data['path'] ?? [];
          distance = data['total_distance']?.toString();
        });
      } else if (response.statusCode == 401) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired, please login again'), backgroundColor: Colors.red),
        );
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error['error'] ?? 'Route not found')),
        );
      }
    } catch (e) {
      print("Navigation error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Navigation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedFrom,
              hint: const Text('Select Start Location'),
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'From',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: locations.map<DropdownMenuItem<String>>((loc) {
                return DropdownMenuItem<String>(
                  value: loc['id'].toString(),
                  child: Text(loc['name']),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedFrom = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedTo,
              hint: const Text('Select Destination'),
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: locations.map<DropdownMenuItem<String>>((loc) {
                return DropdownMenuItem<String>(
                  value: loc['id'].toString(),
                  child: Text(loc['name']),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedTo = val),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : findRoute,
                icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.navigation),
                label: Text(isLoading ? 'Finding...' : 'Find Route'),
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 20),
            if (distance != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Distance:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$distance meters', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Expanded(
              child: path.isEmpty
                  ? const Center(child: Text('Select locations to see the path', style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: path.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final step = path[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(step['name'] ?? 'Point'),
                          subtitle: Text('Type: ${step['type'] ?? ''} | Floor: ${step['floor'] ?? 0}'),
                          trailing: index < path.length - 1 ? const Icon(Icons.arrow_downward, size: 16) : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}