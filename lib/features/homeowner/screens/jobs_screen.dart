import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/job_card.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load jobs when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeownerId = context.read<AuthProvider>().userId;
      if (homeownerId != null) {
        context.read<JobProvider>().loadJobs(homeownerId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getStatusForTab(int tabIndex) {
    // TODO: Move job status types to an enum or constants file
    // TODO: Add support for custom status types based on business requirements
    // Reference statuses kept for implementation:
    switch (tabIndex) {
      case 0:
        return 'active'; // Reference status
      case 1:
        return 'scheduled'; // Reference status
      case 2:
        return 'completed'; // Reference status
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'My Jobs',
          style: AppTextStyles.h2,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Scheduled'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          if (jobProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            );
          }

          if (jobProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load jobs',
                    style: AppTextStyles.bodyLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      final homeownerId = context.read<AuthProvider>().userId;
                      if (homeownerId != null) {
                        jobProvider.loadJobs(homeownerId);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [0, 1, 2].map((tabIndex) {
              final status = _getStatusForTab(tabIndex);
              final jobs = jobProvider.getJobsByStatus(status);

              if (jobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${status.toLowerCase()} jobs',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: JobCard(
                      jobType: status,
                      jobTitle: job.title,
                      electricianName:
                          'Mike Johnson', // TODO: Get from electrician
                      date: job.date.toString(), // TODO: Format date
                      status: job.status,
                      amount: '\$${job.price.toStringAsFixed(2)}',
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
