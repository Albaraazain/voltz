import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voltz/core/services/logger_service.dart';
import 'package:voltz/features/electrician/widgets/job_request_card.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/loading_indicator.dart';

class JobRequestsScreen extends StatefulWidget {
  const JobRequestsScreen({super.key});

  @override
  State<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends State<JobRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final dbProvider = context.read<DatabaseProvider>();
    final electrician = dbProvider.electricians.firstWhere(
      (e) => e.profile.id == dbProvider.currentProfile?.id,
      orElse: () => throw Exception('Electrician profile not found'),
    );
    await context
        .read<JobProvider>()
        .loadJobs(electrician.id, isElectrician: true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Job Requests',
          style: AppTextStyles.h2,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'New Requests'),
            Tab(text: 'Scheduled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList('new'),
          _buildRequestsList('scheduled'),
        ],
      ),
    );
  }

  Widget _buildRequestsList(String type) {
    return Consumer2<JobProvider, DatabaseProvider>(
      builder: (context, jobProvider, dbProvider, child) {
        if (jobProvider.isLoading) {
          return const Center(child: LoadingIndicator());
        }

        if (jobProvider.error != null) {
          return Center(
            child: Text('Error loading jobs: ${jobProvider.error}'),
          );
        }

        final electrician = dbProvider.electricians.firstWhere(
          (e) => e.profile.id == dbProvider.currentProfile?.id,
          orElse: () => throw Exception('Electrician profile not found'),
        );

        final jobs = jobProvider.getJobsByType(type, electrician.id);

        LoggerService.debug(
            'Filtered ${jobs.length} jobs for tab: $type - ${jobs.map((j) => '${j.id}: ${j.status}').join(', ')}');

        if (jobs.isEmpty) {
          return Center(
            child: Text(
              type == 'new' ? 'No new job requests' : 'No scheduled jobs',
              style: AppTextStyles.bodyLarge,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadJobs,
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: JobRequestCard(
                  customerName:
                      job.homeowner?.profile.name ?? 'Unknown Customer',
                  jobType: job.title,
                  date: type == 'new'
                      ? 'Requested ${_formatTimeAgo(job.createdAt)}'
                      : _formatDate(job.date),
                  address: job.homeowner?.address ?? 'No address provided',
                  description: job.description,
                  status: type,
                  onAccept: () {
                    // Store scaffold messenger before async operation
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    jobProvider.acceptJob(job.id, electrician.id).then((_) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Job accepted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }).catchError((error) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Failed to accept job: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    });
                  },
                  onDecline: () {
                    // Store scaffold messenger before async operation
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    jobProvider.declineJob(job.id, electrician.id).then((_) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Job declined'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }).catchError((error) {
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text('Failed to decline job: $error'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    });
                  },
                  onReschedule: () {
                    // Store scaffold messenger before showing message
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Reschedule feature coming soon'),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDate(DateTime dateTime) {
    // TODO: Use intl package for better date formatting
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
