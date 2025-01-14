import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../widgets/electrician_card.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/loading_indicator.dart';

class ElectricianListScreen extends StatefulWidget {
  const ElectricianListScreen({super.key});

  @override
  State<ElectricianListScreen> createState() => _ElectricianListScreenState();
}

class _ElectricianListScreenState extends State<ElectricianListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = 'All';
  bool _showVerifiedOnly = true;
  String _sortBy = 'rating';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedSpecialty == value,
      onSelected: (bool selected) {
        setState(() {
          _selectedSpecialty = selected ? value : 'All';
        });
      },
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.accent,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: _selectedSpecialty == value
            ? AppColors.accent
            : AppColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Find an Electrician', style: AppTextStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // TODO: Show filter modal
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or specialty',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Residential', 'Residential'),
                const SizedBox(width: 8),
                _buildFilterChip('Commercial', 'Commercial'),
                const SizedBox(width: 8),
                _buildFilterChip('Industrial', 'Industrial'),
                const SizedBox(width: 8),
                _buildFilterChip('Emergency', 'Emergency'),
              ],
            ),
          ),

          // Sort and Filter Options
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Verified Only Toggle
                Row(
                  children: [
                    Checkbox(
                      value: _showVerifiedOnly,
                      onChanged: (value) {
                        setState(() {
                          _showVerifiedOnly = value ?? true;
                        });
                      },
                    ),
                    const Text('Verified Only'),
                  ],
                ),
                const Spacer(),
                // Sort Dropdown
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                    DropdownMenuItem(value: 'price', child: Text('Price')),
                    DropdownMenuItem(value: 'jobs', child: Text('Experience')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value ?? 'rating';
                    });
                  },
                ),
              ],
            ),
          ),

          // Electrician List
          Expanded(
            child: Consumer<DatabaseProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator();
                }

                var electricians = provider.electricians;

                // Apply filters
                if (_showVerifiedOnly) {
                  electricians =
                      electricians.where((e) => e.isVerified).toList();
                }
                if (_selectedSpecialty != 'All') {
                  electricians = electricians
                      .where((e) => e.specialties.contains(_selectedSpecialty))
                      .toList();
                }
                if (_searchController.text.isNotEmpty) {
                  final query = _searchController.text.toLowerCase();
                  electricians = electricians.where((e) {
                    return e.profile.name.toLowerCase().contains(query) ||
                        e.specialties
                            .any((s) => s.toLowerCase().contains(query));
                  }).toList();
                }

                // Apply sorting
                electricians.sort((a, b) {
                  switch (_sortBy) {
                    case 'rating':
                      return b.rating.compareTo(a.rating);
                    case 'price':
                      return a.hourlyRate.compareTo(b.hourlyRate);
                    case 'jobs':
                      return b.jobsCompleted.compareTo(a.jobsCompleted);
                    default:
                      return 0;
                  }
                });

                if (electricians.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No electricians found',
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: electricians.length,
                  itemBuilder: (context, index) {
                    final electrician = electricians[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ElectricianCard(
                        name: electrician.profile.name,
                        rating: electrician.rating,
                        specialty: electrician.specialties.isNotEmpty
                            ? electrician.specialties.join(" & ")
                            : 'General Electrician',
                        price:
                            '\$${electrician.hourlyRate.toStringAsFixed(0)}/hr',
                        distance:
                            '2.5 km away', // TODO: Add location calculation
                        availability: electrician.isAvailable
                            ? 'Available Today'
                            : 'Unavailable',
                        isVerified: electrician.isVerified,
                        id: electrician.id,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
