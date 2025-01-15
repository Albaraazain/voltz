import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../widgets/job_status_card.dart';
import '../widgets/recent_electrician_card.dart';
import '../../../providers/notification_provider.dart';
import 'all_electricians_screen.dart';
import '../../../core/services/logger_service.dart';

class HomeownerHomeScreen extends StatefulWidget {
  const HomeownerHomeScreen({super.key});

  @override
  State<HomeownerHomeScreen> createState() => _HomeownerHomeScreenState();
}

class _HomeownerHomeScreenState extends State<HomeownerHomeScreen> {
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      // Start listening to notifications
      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.startListeningToNotifications();
      notificationProvider
          .loadNotifications(); // Load notifications immediately
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh count when returning from notifications screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refreshUnreadCount();
    });
  }

  @override
  void dispose() {
    // Stop listening to notifications
    context.read<NotificationProvider>().stopListeningToNotifications();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final dbProvider = context.read<DatabaseProvider>();

      // Load initial data if needed
      if (dbProvider.currentProfile == null) {
        await dbProvider.loadInitialData();
      } else if (dbProvider.electricians.isEmpty) {
        await dbProvider.loadElectricians();
      }

      if (mounted) {
        setState(() {
          _isInitialLoad = false;
        });
      }
    } catch (e) {
      LoggerService.error('Failed to load homeowner data', e);
      if (mounted) {
        setState(() {
          _isInitialLoad = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load data. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = context.watch<DatabaseProvider>();

    if (_isInitialLoad || dbProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
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
        child: RefreshIndicator(
          onRefresh: _loadData,
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
                              Consumer<DatabaseProvider>(
                                builder: (context, provider, child) {
                                  return Text(
                                    provider.currentProfile?.name ?? 'Welcome',
                                    style: AppTextStyles.h2,
                                  );
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              // Navigate to notifications screen
                              Navigator.pushNamed(context, '/notifications');
                            },
                            icon: Consumer<NotificationProvider>(
                              builder: (context, provider, child) {
                                final unreadCount = provider.unreadCount.when(
                                  initial: () => 0,
                                  loading: () => 0,
                                  error: (_) => 0,
                                  success: (count) => count,
                                );
                                return Badge(
                                  label: Text(unreadCount.toString()),
                                  child:
                                      const Icon(Icons.notifications_outlined),
                                );
                              },
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AllElectriciansScreen(),
                                ),
                              );
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
              Consumer<DatabaseProvider>(
                builder: (context, databaseProvider, child) {
                  if (databaseProvider.isLoading) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.accent),
                          ),
                        ),
                      ),
                    );
                  }

                  final electricians = databaseProvider.electricians;

                  if (electricians.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            'No electricians found',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= electricians.length) return null;
                        final electrician = electricians[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 8.0,
                          ),
                          child: RecentElectricianCard(
                            name: electrician.profile.name,
                            rating: electrician.rating,
                            specialty: electrician.specialties.isNotEmpty
                                ? electrician.specialties[0]
                                : 'General Electrician',
                            jobsCompleted: electrician.jobsCompleted,
                            isVerified: electrician.isVerified,
                            id: electrician.id,
                          ),
                        );
                      },
                      childCount: electricians.length
                          .clamp(0, 5), // Show max 5 recent electricians
                    ),
                  );
                },
              ),

              // Bottom Padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
