import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../models/electrician_model.dart';
import '../widgets/availability_viewer.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/loading_indicator.dart';

class ElectricianProfileViewScreen extends StatelessWidget {
  final String electricianId;

  const ElectricianProfileViewScreen({
    super.key,
    required this.electricianId,
  });

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: LoadingIndicator(),
          );
        }

        final electrician = provider.electricians.firstWhere(
          (e) => e.id == electricianId,
          orElse: () => throw Exception('Electrician not found'),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.primary,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.surface,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              electrician.profile.name,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                            if (electrician.isVerified) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 24,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Profile Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    electrician.rating.toString(),
                                    style: AppTextStyles.h3,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rating',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                electrician.jobsCompleted.toString(),
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Jobs',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                '\$${electrician.hourlyRate.toStringAsFixed(0)}/hr',
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rate',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Info Section
                      Text('Information', style: AppTextStyles.h3),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.work_outline,
                        'Experience',
                        '${electrician.yearsOfExperience} years',
                      ),
                      _buildInfoRow(
                        Icons.engineering,
                        'Specialties',
                        electrician.specialties.join(', '),
                      ),
                      _buildInfoRow(
                        Icons.badge_outlined,
                        'License',
                        electrician.licenseNumber,
                      ),
                      _buildInfoRow(
                        Icons.phone_outlined,
                        'Phone',
                        electrician.phone,
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Availability Section
                      Text('Availability', style: AppTextStyles.h3),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 400,
                        child: AvailabilityViewer(
                          electricianId: electrician.id,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                onPressed: () {
                  // TODO: Navigate to booking screen
                },
                text: 'Book Appointment',
                type: ButtonType.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
