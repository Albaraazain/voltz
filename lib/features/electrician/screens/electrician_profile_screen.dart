import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/service_item.dart';
import '../widgets/review_card.dart';
import '../../common/widgets/custom_button.dart';

class ElectricianProfileScreen extends StatelessWidget {
  const ElectricianProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: AppColors.primary,
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                            color: AppColors.surface,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Mike Johnson',
                          style: AppTextStyles.h2.copyWith(
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
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // TODO: Navigate to edit profile
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
                  _buildStat('4.9', 'Rating', Icons.star),
                  _buildStat('156', 'Jobs', Icons.work),
                  _buildStat('2 yrs', 'Experience', Icons.timer),
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
                          // TODO: Navigate to edit services
                        },
                        child: Text(
                          'Edit',
                          style: AppTextStyles.link,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ServiceItem(
                    title: 'Residential Electrical Service',
                    price: '\$50/hr',
                    description: 'Complete electrical solutions for homes',
                  ),
                  const ServiceItem(
                    title: 'Emergency Repairs',
                    price: '\$75/hr',
                    description: '24/7 emergency electrical repair service',
                  ),
                  const ServiceItem(
                    title: 'Installation Service',
                    price: '\$60/hr',
                    description: 'Installation of electrical equipment and fixtures',
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
                          // TODO: Navigate to all reviews
                        },
                        child: Text(
                          'See All',
                          style: AppTextStyles.link,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ReviewCard(
                    customerName: 'John Smith',
                    rating: 5,
                    comment: 'Excellent service! Very professional and timely.',
                    date: '2 days ago',
                  ),
                  const ReviewCard(
                    customerName: 'Sarah Johnson',
                    rating: 4,
                    comment: 'Good work, would recommend.',
                    date: '1 week ago',
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
                      // TODO: Navigate to availability settings
                    },
                  ),
                  _buildSettingsButton(
                    'Payment Information',
                    Icons.payment_outlined,
                    () {
                      // TODO: Navigate to payment settings
                    },
                  ),
                  _buildSettingsButton(
                    'Notifications',
                    Icons.notifications_outlined,
                    () {
                      // TODO: Navigate to notification settings
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: () {
                      // TODO: Handle sign out
                    },
                    text: 'Sign Out',
                    type: ButtonType.secondary,
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      ),
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