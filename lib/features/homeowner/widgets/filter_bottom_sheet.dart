import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../common/widgets/custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  double _maxPrice = 100;
  double _maxDistance = 10;
  final List<String> _selectedServices = [];

  final List<String> _services = [
    'Residential',
    'Commercial',
    'Emergency',
    'Installation',
    'Repair',
    'Maintenance',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Filter Search',
              style: AppTextStyles.h2,
            ),
          ),
          // Filters
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  Text('Maximum Price per Hour', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '\$${_maxPrice.toInt()}',
                        style: AppTextStyles.bodyLarge,
                      ),
                      Expanded(
                        child: Slider(
                          value: _maxPrice,
                          min: 0,
                          max: 200,
                          activeColor: AppColors.accent,
                          inactiveColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _maxPrice = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Distance
                  Text('Maximum Distance', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        '${_maxDistance.toInt()} km',
                        style: AppTextStyles.bodyLarge,
                      ),
                      Expanded(
                        child: Slider(
                          value: _maxDistance,
                          min: 1,
                          max: 50,
                          activeColor: AppColors.accent,
                          inactiveColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _maxDistance = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Services
                  Text('Services', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _services.map((service) {
                      final isSelected = _selectedServices.contains(service);
                      return FilterChip(
                        label: Text(service),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedServices.add(service);
                            } else {
                              _selectedServices.remove(service);
                            }
                          });
                        },
                        backgroundColor: AppColors.surface,
                        selectedColor: AppColors.primary,
                        checkmarkColor: AppColors.accent,
                        labelStyle: AppTextStyles.bodySmall.copyWith(
                          color: isSelected ? AppColors.accent : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.accent : AppColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  // Availability
                  Text('Availability', style: AppTextStyles.h3),
                  const SizedBox(height: 16),
                  _buildAvailabilityOption(
                    'Available Today',
                    'Find electricians who can help you today',
                  ),
                  _buildAvailabilityOption(
                    'Available This Week',
                    'Plan your electrical work this week',
                  ),
                  _buildAvailabilityOption(
                    'Custom Date',
                    'Choose a specific date',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    text: 'Reset',
                    type: ButtonType.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    onPressed: () {
                      // Apply filters
                      Navigator.pop(context);
                    },
                    text: 'Apply',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityOption(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Radio(
              value: title,
              groupValue: 'Available Today', // Default selection
              onChanged: (value) {
                // Handle radio selection
              },
              activeColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}