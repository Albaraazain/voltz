import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../widgets/job_request_card.dart';

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
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: JobRequestCard(
            customerName: 'Sarah Johnson',
            jobType: 'Electrical Installation',
            date: type == 'new' ? 'Requested 2h ago' : 'Tomorrow, 10:00 AM',
            address: '123 Main St, City',
            description: 'Need help installing new light fixtures in living room...',
            status: type,
            onAccept: () {
              // TODO: Handle accept request
            },
            onDecline: () {
              // TODO: Handle decline request
            },
            onReschedule: () {
              // TODO: Handle reschedule request
            },
          ),
        );
      },
    );
  }
}