/// Author / Project Supervisor : Omar Terro
/// GitHub                      : https://github.com/IOTERRO
/// Website                     : https://omarterro.fr
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni - Smart University CityU
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  
  final String baseUrl = "https://smart-university-api.khaledothman750.workers.dev";

  bool loading = false;

  List<dynamic> courses = [];
  String? selectedCourse;

  String sessionStatus = "No active session";
  String qrSecret = "";

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    setState(() {
      loading = true;
    });

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/courses"),
      );

      if (response.statusCode == 200) {
        setState(() {
          courses = jsonDecode(response.body);
        });
      }
    } catch (e) {
      debugPrint("Courses error: $e");
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> startSession() async {
    if (selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a course first."),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/attendance/session"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "course_id": selectedCourse,
          "instructor_id": "INS001",
        }),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final data = jsonDecode(response.body);

        setState(() {
          sessionStatus = "Attendance session is active";
          qrSecret = data["qr_secret"]?.toString() ?? "";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Attendance session started."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to start session: ${response.body}",
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Connection error: $e"),
        ),
      );
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Attendance"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,

                children: [

                  const Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Attendance System",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: "Select Course",
                      border: OutlineInputBorder(),
                    ),

                  

                    items: courses.map<DropdownMenuItem<String>>(
                      (course) {
                        return DropdownMenuItem<String>(
                          value: course["id"].toString(),
                          child: Text(
                            course["name"]?.toString() ??
                                course["code"]?.toString() ??
                                "Course",
                          ),
                        );
                      },
                    ).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedCourse = value;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed: startSession,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text(
                      "Start Attendance Session",
                    ),
                    style: ElevatedButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Column(
                        children: [

                          const Text(
                            "Session Status",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            sessionStatus,
                            textAlign: TextAlign.center,
                          ),

                          if (qrSecret.isNotEmpty) ...[
                            const SizedBox(height: 20),

                            const Text(
                              "QR Secret",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            SelectableText(
                              qrSecret,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}