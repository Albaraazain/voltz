import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../widgets/job_status_card.dart';
import '../widgets/recent_electrician_card.dart';

class HomeownerHomeScreen extends StatefulWidget {
  const HomeownerHomeScreen({super.key});

  @override
  State<HomeownerHomeScreen> createState() => _HomeownerHomeScreenState();
}

class _HomeownerHomeScreenState extends State<HomeownerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load electricians when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DatabaseProvider>().loadElectricians();
    });
  }

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
    );
  }
}
