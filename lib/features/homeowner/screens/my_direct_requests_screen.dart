import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/direct_request_model.dart';
import '../../../providers/direct_request_provider.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/loading_indicator.dart';

class MyDirectRequestsScreen extends StatefulWidget {
  const MyDirectRequestsScreen({super.key});

  @override
  State<MyDirectRequestsScreen> createState() => _MyDirectRequestsScreenState();
}

class _MyDirectRequestsScreenState extends State<MyDirectRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      final homeownerId = context.read<DatabaseProvider>().currentHomeowner!.id;
      await context
          .read<DirectRequestProvider>()
          .loadHomeownerRequests(homeownerId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load requests')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildRequestCard(DirectRequest request) {
    final statusColor = switch (request.status) {
      DirectRequest.STATUS_PENDING => Colors.orange,
      DirectRequest.STATUS_ACCEPTED => Colors.green,
      DirectRequest.STATUS_DECLINED => Colors.red,
      _ => Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Request to Electrician',
                  style: AppTextStyles.h3,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.statusText,
                    style:
                        AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Preferred Date: ${request.formattedPreferredDate}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Preferred Time: ${request.formattedPreferredTime}',
              style: AppTextStyles.bodyMedium,
            ),
            if (request.message != null) ...[
              const SizedBox(height: 16),
              Text(
                'Message:',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                request.message!,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestProvider = context.watch<DirectRequestProvider>();
    final pendingRequests = requestProvider.pendingRequests;
    final acceptedRequests = requestProvider.acceptedRequests;
    final declinedRequests = requestProvider.declinedRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'My Direct Requests',
          style: AppTextStyles.h2,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Declined'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Pending Requests Tab
                pendingRequests.isEmpty
                    ? Center(
                        child: Text(
                          'No pending requests',
                          style: AppTextStyles.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: pendingRequests.length,
                        itemBuilder: (context, index) =>
                            _buildRequestCard(pendingRequests[index]),
                      ),

                // Accepted Requests Tab
                acceptedRequests.isEmpty
                    ? Center(
                        child: Text(
                          'No accepted requests',
                          style: AppTextStyles.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: acceptedRequests.length,
                        itemBuilder: (context, index) =>
                            _buildRequestCard(acceptedRequests[index]),
                      ),

                // Declined Requests Tab
                declinedRequests.isEmpty
                    ? Center(
                        child: Text(
                          'No declined requests',
                          style: AppTextStyles.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: declinedRequests.length,
                        itemBuilder: (context, index) =>
                            _buildRequestCard(declinedRequests[index]),
                      ),
              ],
            ),
    );
  }
}
