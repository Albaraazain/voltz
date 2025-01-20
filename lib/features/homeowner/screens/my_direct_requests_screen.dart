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
    _tabController = TabController(length: 5, vsync: this);
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
      DirectRequest.STATUS_CANCELLED => Colors.grey,
      DirectRequest.STATUS_RESCHEDULED => Colors.blue,
      DirectRequest.STATUS_IN_PROGRESS => Colors.purple,
      DirectRequest.STATUS_COMPLETED => Colors.teal,
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
                  'Request #${request.id.substring(0, 8)}',
                  style: AppTextStyles.bodyLarge,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.statusText,
                    style: TextStyle(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Preferred Date: ${request.formattedPreferredDate}',
              style: AppTextStyles.bodyMedium,
            ),
            Text(
              'Preferred Time: ${request.formattedPreferredTime}',
              style: AppTextStyles.bodyMedium,
            ),
            if (request.alternativeDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Alternative Date: ${request.alternativeDate}',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.blue),
              ),
              Text(
                'Alternative Time: ${request.alternativeTime}',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.blue),
              ),
              if (request.alternativeMessage != null)
                Text(
                  'Message: ${request.alternativeMessage}',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.blue),
                ),
            ],
            if (request.status == DirectRequest.STATUS_PENDING ||
                request.status == DirectRequest.STATUS_ACCEPTED) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showCancelDialog(request),
                    child: const Text('Cancel Request'),
                  ),
                ],
              ),
            ],
            if (request.status == DirectRequest.STATUS_RESCHEDULED) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _acceptReschedule(request),
                    child: const Text('Accept New Time'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _showCancelDialog(request),
                    child: const Text('Cancel Request'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(DirectRequest request) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this request?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await context.read<DirectRequestProvider>().cancelRequest(
              requestId: request.id,
              reason: reasonController.text.trim(),
              isCancelledByHomeowner: true,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request cancelled successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel request')),
          );
        }
      }
    }
  }

  Future<void> _acceptReschedule(DirectRequest request) async {
    try {
      await context.read<DirectRequestProvider>().updateRequestStatus(
            requestId: request.id,
            status: DirectRequest.STATUS_ACCEPTED,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New time accepted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept new time')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Requests'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
            Tab(text: 'Others'),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRequestsList(
                    context.watch<DirectRequestProvider>().pendingRequests),
                _buildRequestsList(
                    context.watch<DirectRequestProvider>().acceptedRequests),
                _buildRequestsList(
                    context.watch<DirectRequestProvider>().inProgressRequests),
                _buildRequestsList(
                    context.watch<DirectRequestProvider>().completedRequests),
                _buildRequestsList([
                  ...context.watch<DirectRequestProvider>().declinedRequests,
                  ...context.watch<DirectRequestProvider>().cancelledRequests,
                ]),
              ],
            ),
    );
  }

  Widget _buildRequestsList(List<DirectRequest> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text('No requests found'),
      );
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) => _buildRequestCard(requests[index]),
    );
  }
}
