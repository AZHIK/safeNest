import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_localization.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final selectedFilterKey = ref.watch(mapFilterProvider);

    final List<Map<String, dynamic>> mockCenters = [
      {
        'name': 'Central Police Station',
        'typeKey': 'filterPolice',
        'distance': '0.8 km',
        'icon': Icons.local_police,
      },
      {
        'name': 'St. Mary\'s Health Center',
        'typeKey': 'filterHealth',
        'distance': '1.2 km',
        'icon': Icons.local_hospital,
      },
      {
        'name': 'Legal Aid Clinic',
        'typeKey': 'filterLegal',
        'distance': '2.5 km',
        'icon': Icons.gavel,
      },
      {
        'name': 'Women\'s Safe House',
        'typeKey': 'filterSupport',
        'distance': '3.1 km',
        'icon': Icons.home_work,
      },
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Mock Map Background
          Container(
            color: Colors.grey[300],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, size: 100, color: Colors.grey),
                  Text(AppTranslations.get('mapPlaceholder', lang)),
                ],
              ),
            ),
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
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                itemCount: mockCenters.length,
                itemBuilder: (context, index) {
                  final center = mockCenters[index];
                  if (selectedFilterKey != 'filterAll' &&
                      center['typeKey'] != selectedFilterKey) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    width: 300,
                    margin: const EdgeInsets.only(right: AppSizes.p12),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radius16),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(center['icon'], color: AppColors.primary),
                                const SizedBox(width: AppSizes.p8),
                                Expanded(
                                  child: Text(
                                    center['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  center['distance'],
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
                                    onPressed: () {},
                                    icon: const Icon(Icons.call, size: 18),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        AppTranslations.get('callButton', lang),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.p8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
