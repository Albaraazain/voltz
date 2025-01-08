import 'package:flutter/material.dart';
import 'package:voltz/core/constants/colors.dart';
import 'package:voltz/core/constants/text_styles.dart';
import 'package:voltz/features/homeowner/widgets/job_status_card.dart';
import 'package:voltz/features/homeowner/widgets/recent_electrician_card.dart';

class HomeownerHomeScreen extends StatelessWidget {
  const HomeownerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'John Doe',
                              style: AppTextStyles.h2,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Show notifications
                          },
                          icon: const Badge(
                            label: Text('2'),
                            child: Icon(Icons.notifications_outlined),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Active Jobs Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Jobs',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 16),
                    const JobStatusCard(
                      jobTitle: 'Electrical Repair',
                      electricianName: 'Mike Johnson',
                      status: 'In Progress',
                      date: 'Today, 2:30 PM',
                      progress: 0.7,
                    ),
                  ],
                ),
              ),
            ),

            // Recent Electricians Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Electricians',
                          style: AppTextStyles.h3,
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to all electricians
                          },
                          child: Text(
                            'See All',
                            style: AppTextStyles.link,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Recent Electricians List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: RecentElectricianCard(
                      name: 'Mike Johnson',
                      rating: 4.8,
                      specialty: 'Residential Electrician',
                      jobsCompleted: 128,
                    ),
                  );
                },
                childCount: 5,
              ),
            ),

            // Bottom Padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}
