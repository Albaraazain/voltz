import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/job_provider.dart';
import '../../../models/job_model.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/logger_service.dart';
import '../widgets/recent_job_card.dart';
import '../../common/widgets/loading_indicator.dart';

class RecentJobsScreen extends StatefulWidget {
  const RecentJobsScreen({super.key});

  @override
  State<RecentJobsScreen> createState() => _RecentJobsScreenState();
}

class _RecentJobsScreenState extends State<RecentJobsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Recent Jobs'),
        backgroundColor: AppColors.surface,
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          // Get jobs that are either active, completed, or in progress
          final jobs = jobProvider.getJobsByStatus(Job.STATUS_ACTIVE) +
              jobProvider.getJobsByStatus(Job.STATUS_COMPLETED) +
              jobProvider.getJobsByStatus(Job.STATUS_IN_PROGRESS);

          if (jobProvider.isLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (jobProvider.error != null) {
            LoggerService.error('Error loading recent jobs', jobProvider.error);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load recent jobs'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (jobs.isEmpty) {
            return Center(
              child: Text(
                'No recent jobs found',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              final customerName =
                  job.homeowner?.profile.name ?? 'Unknown Customer';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RecentJobCard(
                  customerName: customerName,
                  jobType: job.title,
                  amount: '\$${job.price.toStringAsFixed(2)}',
                  date: job.date.toString(),
                  status: job.status,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/electrician/job-details',
                      arguments: job,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
