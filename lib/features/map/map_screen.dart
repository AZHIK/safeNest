import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';
import '../../core/models/support_center_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_controller.dart';

class MapFilterNotifier extends Notifier<String> {
  @override
  String build() => 'filterAll';

  void setFilter(String filter) => state = filter;
}

final mapFilterProvider = NotifierProvider<MapFilterNotifier, String>(
  () => MapFilterNotifier(),
);

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'police':
        return Icons.local_police;
      case 'hospital':
        return Icons.local_hospital;
      case 'legal_aid':
        return Icons.gavel;
      case 'ngo':
      case 'shelter':
      case 'hotline':
      case 'counseling':
        return Icons.home_work;
      default:
        return Icons.location_on;
    }
  }

  Future<void> _launchPhone(BuildContext context, String? phone) async {
    if (phone == null) return;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Show error if launch failed
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open dialer app')),
          );
        }
      }
    } else {
      // Show error if no app can handle the URL
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No dialer app found on this device')),
        );
      }
    }
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final selectedFilterKey = ref.watch(mapFilterProvider);
    final centersAsync = ref.watch(nearbyCentersProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Actual Google Map Background
          Builder(
            builder: (context) {
              final centers = centersAsync.value ?? [];

              // Default to Dar es Salaam if no centers to center around
              final initialPos = centers.isNotEmpty
                  ? LatLng(centers.first.latitude, centers.first.longitude)
                  : const LatLng(-6.7924, 39.2083);

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialPos,
                  zoom: 12.0,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: centers
                    .map(
                      (c) => Marker(
                        markerId: MarkerId(c.id),
                        position: LatLng(c.latitude, c.longitude),
                        infoWindow: InfoWindow(
                          title: c.name,
                          snippet: c.phonePrimary,
                        ),
                      ),
                    )
                    .toSet(),
              );
            },
          ),

          // Header / Search area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radius12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                        vertical: AppSizes.p4,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: AppTranslations.get(
                            'searchCentersHint',
                            lang,
                          ),
                          border: InputBorder.none,
                          icon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          [
                            'filterAll',
                            'filterPolice',
                            'filterHealth',
                            'filterLegal',
                            'filterSupport',
                          ].map((key) {
                            final isSelected = selectedFilterKey == key;
                            return Padding(
                              padding: const EdgeInsets.only(
                                right: AppSizes.p8,
                              ),
                              child: ChoiceChip(
                                label: Text(AppTranslations.get(key, lang)),
                                selected: isSelected,
                                onSelected: (val) => ref
                                    .read(mapFilterProvider.notifier)
                                    .setFilter(key),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nearby Centers Horizontal List
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 180,
              padding: const EdgeInsets.only(bottom: AppSizes.p16),
              child: centersAsync.when(
                data: (centers) {
                  if (centers.isEmpty) {
                    return Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSizes.p16),
                          child: Text(
                            AppTranslations.get('noCentersFound', lang),
                          ), // Or a specific "No centers found"
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                    ),
                    itemCount: centers.length,
                    itemBuilder: (context, index) {
                      final center = centers[index];

                      return Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: AppSizes.p12),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radius16,
                            ),
                          ),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.p16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _getIconForType(center.centerType),
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: AppSizes.p8),
                                    Expanded(
                                      child: Text(
                                        center.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (center.distanceKm != null)
                                      Text(
                                        '${center.distanceKm!.toStringAsFixed(1)} km',
                                        style: const TextStyle(
                                          fontSize: AppSizes.fontSmall,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: center.phonePrimary != null
                                            ? () => _launchPhone(
                                                context,
                                                center.phonePrimary,
                                              )
                                            : null,
                                        icon: const Icon(Icons.call, size: 18),
                                        label: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            AppTranslations.get(
                                              'callButton',
                                              lang,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.p8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _launchMaps(
                                          center.latitude,
                                          center.longitude,
                                        ),
                                        icon: const Icon(
                                          Icons.directions,
                                          size: 18,
                                        ),
                                        label: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            AppTranslations.get(
                                              'directionsButton',
                                              lang,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
