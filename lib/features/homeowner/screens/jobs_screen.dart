import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../models/job_model.dart';
import '../widgets/job_card.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  final _focusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadJobs();
    });
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _loadJobs();
    }
  }

  Future<void> _loadJobs() async {
    final databaseProvider = context.read<DatabaseProvider>();
    final homeowner = databaseProvider.currentHomeowner;

    if (homeowner != null) {
      await context.read<JobProvider>().loadJobs(homeowner.id);
    } else if (!databaseProvider.isLoading) {
      await databaseProvider.loadCurrentProfile();
      if (mounted) {
        final updatedHomeowner = databaseProvider.currentHomeowner;
        if (updatedHomeowner != null) {
          await context.read<JobProvider>().loadJobs(updatedHomeowner.id);
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _getStatusForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return Job.STATUS_PENDING;
      case 1:
        return Job.STATUS_IN_PROGRESS;
      case 2:
        return Job.STATUS_COMPLETED;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
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
                      _loadJobs();
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
                        'No ${status.toLowerCase().replaceAll('_', ' ')} jobs',
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
                      jobType: status.toLowerCase().replaceAll('_', ' '),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-job');
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
