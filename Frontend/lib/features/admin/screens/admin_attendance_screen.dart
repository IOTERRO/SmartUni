import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/remote/worker_api_client.dart';
import '../../../data/repositories/repository_hub.dart';

/// Admin attendance — live sessions/records from the Attendance Worker.
class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _records = [];
  String? _sessionId;
  bool _loadingSessions = true;
  bool _loadingRecords = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _loadingSessions = true;
      _error = null;
    });
    try {
      final sessions =
          await RepositoryHub.instance.attendance.fetchSessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
        _sessionId = sessions.isNotEmpty
            ? sessions.first['id']?.toString()
            : null;
        _loadingSessions = false;
      });
      if (_sessionId != null) {
        await _loadRecords(_sessionId!);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingSessions = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingSessions = false;
        _error = 'Could not load attendance sessions.';
      });
    }
  }

  Future<void> _loadRecords(String sessionId) async {
    setState(() {
      _loadingRecords = true;
      _error = null;
      _sessionId = sessionId;
    });
    try {
      final records = await RepositoryHub.instance.attendance.fetchRecords(
        sessionId: sessionId,
      );
      if (!mounted) return;
      setState(() {
        _records = records;
        _loadingRecords = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingRecords = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingRecords = false;
        _error = 'Could not load attendance records.';
      });
    }
  }

  String _formatScanTime(Object? raw) {
    if (raw == null) return '—';
    final text = raw.toString();
    if (text.length >= 16) {
      // 2026-10-13T09:05:00Z → 09:05
      final t = text.substring(11, 16);
      return t;
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin · Attendance'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loadingSessions ? null : _loadSessions,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _loadingSessions
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  const SectionHeader(
                    title: 'Attendance records',
                    subtitle:
                        'Live data from Cloudflare (smart-university-db).',
                  ),
                  const SizedBox(height: 14),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (_sessions.isEmpty)
                    const Text('No attendance sessions found in D1.')
                  else ...[
                    DropdownButtonFormField<String>(
                      key: ValueKey(_sessionId),
                      initialValue: _sessionId,
                      decoration:
                          const InputDecoration(labelText: 'Session'),
                      items: _sessions
                          .map(
                            (s) => DropdownMenuItem(
                              value: s['id']?.toString(),
                              child: Text(
                                '${s['course_id'] ?? ''} · ${s['session_date'] ?? ''} ${s['start_time'] ?? ''}'
                                    .trim(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _loadRecords(v);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_loadingRecords)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_records.isEmpty)
                      const Text('No records for this session.')
                    else
                      ..._records.map((row) {
                        final status =
                            (row['status'] as String? ?? 'Absent').trim();
                        final present = status.toLowerCase() == 'present';
                        final name =
                            row['student_name']?.toString() ?? 'Student';
                        final sid =
                            row['student_id']?.toString() ?? '';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  (present ? AppColors.success : AppColors.danger)
                                      .withOpacity(0.12),
                              child: Icon(
                                present
                                    ? Icons.check_rounded
                                    : Icons.close_rounded,
                                color: present
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                            title: Text(
                              name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(sid),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  status,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: present
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ),
                                Text(
                                  _formatScanTime(row['scanned_at']),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ],
              ),
      ),
    );
  }
}
