import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class ElectricianCard extends StatelessWidget {
  final String name;
  final double rating;
  final String specialty;
  final String price;
  final String distance;
  final String availability;
  final bool isVerified;

  const ElectricianCard({
    super.key,
    required this.name,
    required this.rating,
    required this.specialty,
    required this.price,
    required this.distance,
    required this.availability,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header with Image and Basic Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.h3,
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                          const Spacer(),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toString(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _InfoChip(
                            icon: Icons.attach_money,
                            label: price,
                          ),
                          const SizedBox(width: 8),
                          _InfoChip(
                            icon: Icons.location_on_outlined,
                            label: distance,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer with Availability and Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    availability,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to electrician profile
                  },
                  child: Row(
                    children: [
                      Text(
                        'View Profile',
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
