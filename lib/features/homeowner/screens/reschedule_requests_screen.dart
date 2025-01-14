import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/reschedule_request_model.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/loading_indicator.dart';

class RescheduleRequestsScreen extends StatefulWidget {
  const RescheduleRequestsScreen({super.key});

  @override
  State<RescheduleRequestsScreen> createState() =>
      _RescheduleRequestsScreenState();
}

class _RescheduleRequestsScreenState extends State<RescheduleRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRescheduleRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRescheduleRequests() async {
    setState(() => _isLoading = true);

    try {
      final homeownerId = context.read<DatabaseProvider>().currentHomeowner!.id;
      final scheduleProvider = context.read<ScheduleProvider>();

      scheduleProvider.setCurrentHomeownerId(homeownerId);
      await scheduleProvider.loadRescheduleRequests(homeownerId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load reschedule requests')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRescheduleAction(String requestId, String action) async {
    try {
      setState(() => _isLoading = true);

      await context.read<ScheduleProvider>().respondToRescheduleRequest(
            requestId,
            action == 'accept' ? 'ACCEPTED' : 'DECLINED',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Request ${action == 'accept' ? 'accepted' : 'declined'}'),
            backgroundColor: action == 'accept' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update request')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildRequestCard(RescheduleRequest request) {
    final isPending = request.status == RescheduleRequest.STATUS_PENDING;

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
                  'Reschedule Request',
                  style: AppTextStyles.h3,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: request.status == RescheduleRequest.STATUS_PENDING
                        ? Colors.orange
                        : request.status == RescheduleRequest.STATUS_ACCEPTED
                            ? Colors.green
                            : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status,
                    style:
                        AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Original Schedule:',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${request.originalDate} at ${request.originalTime}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Proposed Schedule:',
              style: AppTextStyles.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${request.proposedDate} at ${request.proposedTime}',
              style: AppTextStyles.bodyMedium,
            ),
            if (request.reason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reason:',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                request.reason!,
                style: AppTextStyles.bodyMedium,
              ),
            ],
            if (isPending && request.requestedByType == 'ELECTRICIAN') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    onPressed: () =>
                        _handleRescheduleAction(request.id, 'decline'),
                    text: 'Decline',
                    type: ButtonType.secondary,
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    onPressed: () =>
                        _handleRescheduleAction(request.id, 'accept'),
                    text: 'Accept',
                    type: ButtonType.primary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final requests = _tabController.index == 0
        ? scheduleProvider.pendingRescheduleRequests
        : _tabController.index == 1
            ? scheduleProvider.acceptedRescheduleRequests
            : scheduleProvider.declinedRescheduleRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reschedule Requests',
          style: AppTextStyles.h2,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: AppTextStyles.bodyMedium,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Declined'),
          ],
          onTap: (_) => setState(() {}),
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : requests.isEmpty
              ? Center(
                  child: Text(
                    'No reschedule requests found',
                    style: AppTextStyles.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) =>
                      _buildRequestCard(requests[index]),
                ),
    );
  }
}
