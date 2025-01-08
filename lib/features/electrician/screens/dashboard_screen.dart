import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_job_card.dart';
import '../widgets/earnings_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.surface,
              title: Text(
                'Dashboard',
                style: AppTextStyles.h2,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // TODO: Show notifications
                  },
                  icon: const Badge(
                    label: Text('3'),
                    child: Icon(Icons.notifications_outlined),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Stats Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'Today\'s Jobs',
                            value: '3',
                            icon: Icons.work,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatsCard(
                            title: 'New Requests',
                            value: '5',
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            title: 'This Week',
                            value: '\$1,250',
                            icon: Icons.attach_money,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatsCard(
                            title: 'Rating',
                            value: '4.8',
                            icon: Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Earnings Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Earnings',
                          style: AppTextStyles.h3,
                        ),
                        DropdownButton<String>(
                          value: 'This Month',
                          items: ['This Week', 'This Month', 'This Year']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: AppTextStyles.bodyMedium,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            // TODO: Handle period change
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      height: 200,
                      child: EarningsChart(),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Jobs Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Jobs',
                          style: AppTextStyles.h3,
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to all jobs
                          },
                          child: Text(
                            'View All',
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

            // Recent Jobs List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: RecentJobCard(
                      customerName: 'Alice Smith',
                      jobType: 'Electrical Repair',
                      amount: '\$120',
                      date: 'Today, 2:30 PM',
                      status: 'Completed',
                    ),
                  );
                },
                childCount: 5,
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}