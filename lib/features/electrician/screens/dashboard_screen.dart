import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/electrician_stats_provider.dart';
import '../../../providers/job_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_job_card.dart';
import '../widgets/earnings_chart.dart';
import '../../common/widgets/loading_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, String> _periodLabels = {
    'week': 'This Week',
    'month': 'This Month',
    'year': 'This Year',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final dbProvider = context.read<DatabaseProvider>();
    if (dbProvider.electricians.isEmpty) {
      await dbProvider.loadCurrentProfile();
    }

    final electrician = dbProvider.electricians.firstWhere(
      (e) => e.profile.id == dbProvider.currentProfile?.id,
      orElse: () => throw Exception('Electrician profile not found'),
    );

    await context.read<ElectricianStatsProvider>().loadStats(electrician.id);
    await context.read<JobProvider>().loadJobs(electrician.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child:
            Consumer3<DatabaseProvider, ElectricianStatsProvider, JobProvider>(
          builder: (context, dbProvider, statsProvider, jobProvider, child) {
            if (dbProvider.isLoading || statsProvider.isLoading) {
              return const LoadingIndicator();
            }

            final electrician = dbProvider.electricians.firstWhere(
              (e) => e.profile.id == dbProvider.currentProfile?.id,
              orElse: () => throw Exception('Electrician profile not found'),
            );

            final stats = statsProvider.stats.data;
            if (stats == null) {
              return const Center(
                child: Text('Failed to load statistics'),
              );
            }

            return CustomScrollView(
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
                        Navigator.pushNamed(context, '/notifications');
                      },
                      icon: Badge(
                        label: Text(stats.unreadNotifications.toString()),
                        child: const Icon(Icons.notifications_outlined),
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
                                value: stats.todayJobs.toString(),
                                icon: Icons.work,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatsCard(
                                title: 'New Requests',
                                value: stats.newRequests.toString(),
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
                                value:
                                    '\$${stats.weeklyEarnings.toStringAsFixed(2)}',
                                icon: Icons.attach_money,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatsCard(
                                title: 'Rating',
                                value: stats.rating.toStringAsFixed(1),
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
                              value: statsProvider.selectedPeriod,
                              items:
                                  ['week', 'month', 'year'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    _periodLabels[value] ?? value,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  statsProvider.updatePeriod(newValue);
                                }
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
                                Navigator.pushNamed(
                                    context, '/electrician/jobs');
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
                if (jobProvider.jobs.hasData && jobProvider.jobs.data != null)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = jobProvider.jobs.data![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: RecentJobCard(
                            customerName: job.homeowner.profile.name,
                            jobType: job.title,
                            amount: '\$${job.price.toStringAsFixed(2)}',
                            date: job.date.toString(),
                            status: job.status,
                          ),
                        );
                      },
                      childCount: jobProvider.jobs.data!.length.clamp(0, 5),
                    ),
                  )
                else
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Text('No recent jobs'),
                    ),
                  ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}
