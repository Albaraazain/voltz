import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/electrician_stats_provider.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/notification_provider.dart';
import '../widgets/stats_card.dart';
import '../widgets/recent_job_card.dart';
import '../widgets/earnings_chart.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../../core/services/logger_service.dart';

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

  bool _isInitialLoad = true;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      context.read<NotificationProvider>().startListeningToNotifications();
    });
  }

  @override
  void dispose() {
    context.read<NotificationProvider>().stopListeningToNotifications();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isRetrying = true;
      });

      final dbProvider = context.read<DatabaseProvider>();

      // Wait for initial data to be loaded
      if (dbProvider.currentProfile == null ||
          dbProvider.electricians.isEmpty) {
        await dbProvider.loadInitialData();
        if (!mounted) return;
      }

      // Double check that we have the current profile after loading
      if (dbProvider.currentProfile == null) {
        LoggerService.debug('Current profile is still null after loading');
        throw Exception('Failed to load profile');
      }

      // Find electrician profile with proper error handling
      final currentProfileId = dbProvider.currentProfile!.id;
      LoggerService.debug(
          'Looking for electrician profile with ID: $currentProfileId');

      final electrician = dbProvider.electricians.firstWhere(
        (e) => e.profile.id == currentProfileId,
        orElse: () {
          LoggerService.debug(
              'Electrician profile not found for ID: $currentProfileId');
          throw Exception('Electrician profile not found');
        },
      );

      // Load stats and jobs in parallel
      await Future.wait([
        context.read<ElectricianStatsProvider>().loadStats(electrician.id),
        context
            .read<JobProvider>()
            .loadJobs(electrician.id, isElectrician: true),
      ]);

      if (mounted) {
        setState(() {
          _isInitialLoad = false;
          _isRetrying = false;
        });
      }
    } catch (e, stackTrace) {
      LoggerService.debug('Dashboard loading error: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          _isInitialLoad = false;
          _isRetrying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load dashboard data'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadData,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = context.watch<DatabaseProvider>();

    if (_isInitialLoad || _isRetrying) {
      return const Scaffold(
        body: Center(
          child: LoadingIndicator(),
        ),
      );
    }

    if (dbProvider.currentProfile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Failed to load profile'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer4<DatabaseProvider, ElectricianStatsProvider,
            JobProvider, NotificationProvider>(
          builder: (context, dbProvider, statsProvider, jobProvider,
              notificationProvider, child) {
            if (_isInitialLoad ||
                dbProvider.isLoading ||
                statsProvider.isLoading) {
              return const Center(
                child: LoadingIndicator(),
              );
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

            return RefreshIndicator(
              onRefresh: _loadData,
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
                          Navigator.pushNamed(context, '/notifications');
                        },
                        icon: Badge(
                          label: Text(notificationProvider.unreadCount.data
                                  ?.toString() ??
                              '0'),
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
                                items: ['week', 'month', 'year']
                                    .map((String value) {
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
                                      context, '/electrician/recent-jobs');
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
                          final customerName =
                              job.homeowner?.profile.name ?? 'Unknown Customer';
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: RecentJobCard(
                              customerName: customerName,
                              jobType: job.title,
                              amount: '\$${job.price.toStringAsFixed(2)}',
                              date: job.date.toString(),
                              status: job.status,
                              onTap: () {
                                // TODO: Navigate to job details
                                Navigator.pushNamed(
                                    context, '/electrician/job-details',
                                    arguments: job);
                              },
                            ),
                          );
                        },
                        childCount: jobProvider.jobs.data!.length.clamp(0, 5),
                      ),
                    )
                  else if (jobProvider.jobs.hasError)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('Failed to load jobs'),
                        ),
                      ),
                    )
                  else
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text('No recent jobs'),
                        ),
                      ),
                    ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
