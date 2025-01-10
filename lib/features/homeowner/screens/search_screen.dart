import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../widgets/electrician_card.dart';
import '../widgets/search_filter_chip.dart';
import '../widgets/filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Residential',
    'Commercial',
    'Emergency',
    'Installation',
    'Repair',
  ];

  @override
  void initState() {
    super.initState();
    // Load electricians when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DatabaseProvider>().loadElectricians();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Search electricians...',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _showFilterBottomSheet(context);
                          },
                          icon: const Icon(
                            Icons.tune,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SearchFilterChip(
                            label: _filters[index],
                            isSelected: _selectedFilter == _filters[index],
                            onTap: () {
                              setState(() {
                                _selectedFilter = _filters[index];
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Search Results
            Expanded(
              child: Consumer<DatabaseProvider>(
                builder: (context, databaseProvider, child) {
                  final electricians = databaseProvider.electricians;

                  if (electricians.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: electricians.length,
                    itemBuilder: (context, index) {
                      final electrician = electricians[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ElectricianCard(
                          name: electrician.name,
                          rating: electrician.rating,
                          specialty:
                              'Residential & Commercial', // TODO: Add to model
                          price:
                              '\$${electrician.hourlyRate.toStringAsFixed(0)}/hr',
                          distance:
                              '2.5 km away', // TODO: Add location calculation
                          availability: electrician.isAvailable
                              ? 'Available Today'
                              : 'Unavailable',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}
