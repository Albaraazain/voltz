import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/electrician_model.dart';
import '../widgets/service_item.dart';
import '../widgets/review_card.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/loading_indicator.dart';

class ElectricianProfileScreen extends StatelessWidget {
  const ElectricianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseProvider>(
      builder: (context, dbProvider, child) {
        if (dbProvider.isLoading) {
          return const LoadingIndicator();
        }

        final electrician = dbProvider.electricians.firstWhere(
          (e) => e.profile.id == dbProvider.currentProfile?.id,
          orElse: () => throw Exception('Electrician profile not found'),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                // Profile Header
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  stretch: true,
                  stretchTriggerOffset: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: AppColors.primary,
                          padding: const EdgeInsets.only(bottom: 48, top: 64),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.accent,
                                    width: 2,
                                  ),
                                  image: electrician.profileImage != null
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              electrician.profileImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: electrician.profileImage == null
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.accent,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                electrician.profile.name,
                                style: AppTextStyles.h2.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (electrician.isVerified) ...[
                                    const Icon(
                                      Icons.verified,
                                      color: AppColors.accent,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Verified',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.accent,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    'License: ${electrician.licenseNumber}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                electrician.phone,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Switch(
                      value: electrician.isAvailable,
                      onChanged: (value) async {
                        await dbProvider.updateElectricianAvailability(
                          electrician.id,
                          value,
                        );
                      },
                      activeColor: AppColors.accent,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(
                            context, '/electrician/edit-profile');
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // Stats Row
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          electrician.rating.toStringAsFixed(1),
                          'Rating',
                          Icons.star,
                        ),
                        _buildStat(
                          electrician.jobsCompleted.toString(),
                          'Jobs',
                          Icons.work,
                        ),
                        _buildStat(
                          '${electrician.yearsOfExperience} yrs',
                          'Experience',
                          Icons.timer,
                        ),
                      ],
                    ),
                  ),
                ),

                // Specialties Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Specialties', style: AppTextStyles.h3),
                        const SizedBox(height: 16),
                        if (electrician.specialties.isEmpty)
                          Center(
                            child: Text(
                              'No specialties added yet',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: electrician.specialties.map((specialty) {
                              return Chip(
                                label: Text(specialty),
                                backgroundColor: AppColors.surface,
                                labelStyle: AppTextStyles.bodySmall,
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),

                // Services Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('My Services', style: AppTextStyles.h3),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/electrician/manage-services');
                              },
                              child: Text(
                                'Edit',
                                style: AppTextStyles.link,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (electrician.services.isEmpty)
                          Center(
                            child: Text(
                              'No services added yet',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        else
                          ...electrician.services.map(
                            (service) => ServiceItem(
                              title: service.title,
                              price: '\$${service.price.toStringAsFixed(2)}/hr',
                              description: service.description,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Reviews Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Reviews', style: AppTextStyles.h3),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/electrician/reviews');
                              },
                              child: Text(
                                'See All',
                                style: AppTextStyles.link,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FutureBuilder(
                          future:
                              dbProvider.getElectricianReviews(electrician.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(child: LoadingIndicator());
                            }

                            if (!snapshot.hasData ||
                                (snapshot.data as List).isEmpty) {
                              return Center(
                                child: Text(
                                  'No reviews yet',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }

                            final reviews = snapshot.data as List;
                            return Column(
                              children: reviews.take(2).map((review) {
                                return ReviewCard(
                                  customerName: review.homeowner.profile.name,
                                  rating: review.rating,
                                  comment: review.comment,
                                  date: review.createdAt,
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Account Settings Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Account Settings', style: AppTextStyles.h3),
                        const SizedBox(height: 16),
                        _buildSettingsButton(
                          'Availability Schedule',
                          Icons.calendar_today_outlined,
                          () {
                            Navigator.pushNamed(
                                context, '/electrician/availability');
                          },
                        ),
                        _buildSettingsButton(
                          'Payment Information',
                          Icons.payment_outlined,
                          () {
                            Navigator.pushNamed(
                                context, '/electrician/payment');
                          },
                        ),
                        _buildSettingsButton(
                          'Notifications',
                          Icons.notifications_outlined,
                          () {
                            Navigator.pushNamed(
                                context, '/electrician/notifications');
                          },
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          onPressed: () async {
                            final authProvider = context.read<AuthProvider>();
                            await authProvider.signOutAndNavigate(context);
                          },
                          text: 'Sign Out',
                          type: ButtonType.secondary,
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Account'),
                                content: const Text(
                                  'Are you sure you want to delete your account? This action cannot be undone. All your data, including job history and reviews, will be permanently deleted.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context
                                          .read<AuthProvider>()
                                          .deleteAccount(context);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          text: 'Delete Account',
                          type: ButtonType.secondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.accent,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h3,
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.accent,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: AppTextStyles.bodyLarge,
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
