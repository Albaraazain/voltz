import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/electrician_model.dart';
import '../../../providers/database_provider.dart';
import '../../../services/logger_service.dart';

class ElectricianProfileViewScreen extends StatelessWidget {
  final String electricianId;

  const ElectricianProfileViewScreen({
    super.key,
    required this.electricianId,
  });

  void _handleBookAppointment(BuildContext context, Electrician electrician) {
    Navigator.pushNamed(
      context,
      '/book_appointment',
      arguments: {
        'electricianId': electrician.id,
        'slot': null,
      },
    );
  }

  void _handleDirectRequest(BuildContext context, Electrician electrician) {
    Navigator.pushNamed(
      context,
      '/direct_request',
      arguments: {
        'electricianId': electrician.id,
        'electricianName': electrician.profile.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final electrician = provider.electricians.firstWhere(
            (e) => e.id == electricianId,
            orElse: () => throw Exception('Electrician not found'),
          );

          return CustomScrollView(
            slivers: [
              // App Bar with Profile Image
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: electrician.profileImage != null
                      ? Image.network(
                          electrician.profileImage!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: AppColors.surface,
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: AppColors.accent,
                          ),
                        ),
                ),
              ),

              // Profile Information
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Verification
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              electrician.profile.name,
                              style: AppTextStyles.h2,
                            ),
                          ),
                          if (electrician.isVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Rating and Jobs
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            electrician.rating.toStringAsFixed(1),
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${electrician.jobsCompleted} jobs completed',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // License and Experience
                      Text(
                        'License Number: ${electrician.licenseNumber}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${electrician.yearsOfExperience} years of experience',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      // Specialties
                      Text(
                        'Specialties',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: electrician.specialties.map((specialty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              specialty,
                              style: AppTextStyles.bodySmall,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Services
                      Text(
                        'Services',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 8),
                      ...electrician.services.map((service) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                service.title,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Hourly Rate
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hourly Rate',
                              style: AppTextStyles.bodyLarge,
                            ),
                            Text(
                              '\$${electrician.hourlyRate.toStringAsFixed(2)}/hr',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Booking Options
                      if (electrician.isAvailable) ...[
                        ElevatedButton(
                          onPressed: () =>
                              _handleBookAppointment(context, electrician),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('Book Appointment'),
                        ),
                      ] else
                        Center(
                          child: Text(
                            'Currently Unavailable',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
