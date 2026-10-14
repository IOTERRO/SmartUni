/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/models/campus_location.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/remote/worker_api_client.dart';
import '../../../data/repositories/repository_hub.dart';

/// Shared Navigation UI for Guest and Student — live Cloudflare locations.
class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  List<CampusLocation> _locations = [];
  String? _fromId;
  String? _toId;
  NavigationRoutePreview? _route;
  bool _loading = true;
  bool _routing = false;
  String _search = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await RepositoryHub.instance.navigation.fetchLocations();
      if (!mounted) return;
      setState(() {
        _locations = list;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load campus locations.';
      });
    }
  }

  List<CampusLocation> get _filtered {
    final q = _search.trim().toLowerCase();
    if (q.isEmpty) return _locations;
    return _locations
        .where(
          (l) =>
              l.name.toLowerCase().contains(q) ||
              l.type.toLowerCase().contains(q) ||
              (l.building?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  Future<void> _findRoute() async {
    if (_fromId == null || _toId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select start and destination.')),
      );
      return;
    }
    if (_fromId == _toId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose two different locations.')),
      );
      return;
    }

    setState(() => _routing = true);
    try {
      final route = await RepositoryHub.instance.navigation.findRoute(
        fromId: _fromId!,
        toId: _toId!,
      );
      if (!mounted) return;
      setState(() => _route = route);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find a route.')),
      );
    } finally {
      if (mounted) setState(() => _routing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Navigation'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  const SectionHeader(
                    title: 'Find your way',
                    subtitle: 'Live campus locations from Cloudflare (cityu).',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search buildings, labs, offices…',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _fromId,
                    decoration: const InputDecoration(labelText: 'From'),
                    items: _filtered
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _fromId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _toId,
                    decoration: const InputDecoration(labelText: 'To'),
                    items: _locations
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(l.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _toId = v),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _routing ? null : _findRoute,
                    icon: _routing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.navigation_rounded),
                    label: Text(_routing ? 'Finding…' : 'Find route'),
                  ),
                  if (_route != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD7E4FF)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total distance',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            '${_route!.totalDistanceMeters.toStringAsFixed(0)} m',
                            style: const TextStyle(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._route!.path.asMap().entries.map((entry) {
                      final i = entry.key;
                      final step = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.navigationAccent.withOpacity(0.12),
                            foregroundColor: AppColors.navigationAccent,
                            child: Text('${i + 1}'),
                          ),
                          title: Text(
                            step.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${step.type} · Floor ${step.floor}'
                            '${step.building != null ? ' · ${step.building}' : ''}',
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 22),
                  const SectionHeader(
                    title: 'Campus directory',
                    subtitle: 'Locations loaded from the Navigation Worker.',
                  ),
                  const SizedBox(height: 10),
                  ..._filtered.map(
                    (l) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.place_outlined, color: AppColors.navigationAccent),
                        title: Text(l.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: Text(l.description ?? l.type),
                        trailing: Text(
                          'F${l.floor}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
