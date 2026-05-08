import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../models/issue_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/issue_provider.dart';
import '../../widgets/app_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _mapController = MapController();
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(allIssuesStreamProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.secondary]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_city_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text('SmartCity'),
          ],
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppTheme.secondary),
              onPressed: () => context.go('/admin'),
              tooltip: 'Admin Panel',
            ),
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () {
              _mapController.move(
                const LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
                AppConstants.defaultZoom,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: ['All', ...AppConstants.categories].map((cat) {
                final selected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      cat == 'All' ? '🗺️ All' : '${AppConstants.categoryIcons[cat]} $cat',
                      style: TextStyle(
                        color: selected ? Colors.white : AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    backgroundColor: AppTheme.cardBg,
                    selectedColor: AppTheme.primary,
                    side: BorderSide(
                      color: selected ? AppTheme.primary : AppTheme.border,
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                );
              }).toList(),
            ),
          ),

          // Map
          Expanded(
            child: issuesAsync.when(
              loading: () => const LoadingWidget(message: 'Loading map...'),
              error: (e, _) => ErrorRetryWidget(
                message: 'Failed to load issues',
                onRetry: () => ref.invalidate(allIssuesStreamProvider),
              ),
              data: (issues) {
                final filtered = _selectedCategory == 'All'
                    ? issues
                    : issues.where((i) => i.category == _selectedCategory).toList();

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
                    initialZoom: AppConstants.defaultZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.smartcity.app',
                    ),
                    MarkerLayer(
                      markers: filtered.map((issue) => _buildMarker(issue)).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/report'),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Report Issue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Marker _buildMarker(IssueModel issue) {
    final color = AppTheme.statusColor(issue.status);
    final emoji = AppConstants.categoryIcons[issue.category] ?? '📌';

    return Marker(
      point: LatLng(issue.latitude, issue.longitude),
      width: 48,
      height: 58,
      child: GestureDetector(
        onTap: () => context.push('/issue/${issue.id}', extra: issue),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2.5),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
            ),
            Container(
              width: 3, height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
