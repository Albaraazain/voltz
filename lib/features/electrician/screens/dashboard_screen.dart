import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/job_model.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../core/services/logger_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final electrician = Provider.of<DatabaseProvider>(context, listen: false)
          .electricians
          .firstWhere((e) =>
              e.profile.id ==
              context.read<DatabaseProvider>().currentProfile?.id);

      await context.read<JobProvider>().loadJobs(electrician.id);

      setState(() {
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      LoggerService.error('Failed to load dashboard data: ${e.toString()}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    }
  }

  Widget _buildJobCard(Job job) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(job.title),
        subtitle: Text(job.description),
        trailing: Text('\$${job.price}'),
        onTap: () {
          // Navigate to job details
          Navigator.pushNamed(
            context,
            '/job-details',
            arguments: {
              'jobId': job.id,
              'homeownerId': job.homeownerId,
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<JobProvider>(
              builder: (context, jobProvider, child) {
                final jobs = jobProvider.jobs.data;
                if (jobs == null || jobs.isEmpty) {
                  return const Center(
                    child: Text('No jobs available'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) => _buildJobCard(jobs[index]),
                );
              },
            ),
    );
  }
}
