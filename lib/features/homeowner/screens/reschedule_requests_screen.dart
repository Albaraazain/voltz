import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/homeowner_provider.dart';
import '../../../models/reschedule_request_model.dart';
import '../../common/widgets/custom_button.dart';

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
      final homeownerId =
          context.read<HomeownerProvider>().getCurrentHomeownerId();
      await context.read<ScheduleProvider>().loadRescheduleRequests(
            userId: homeownerId,
            userType: 'HOMEOWNER',
          );
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
            requestId: requestId,
            status: action == 'accept'
                ? RescheduleRequest.STATUS_ACCEPTED
                : RescheduleRequest.STATUS_DECLINED,
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
            if (isPending) ...[
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
          onTap: (_) => setState(() {}),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Declined'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? Center(
                  child: Text(
                    'No ${_tabController.index == 0 ? 'pending' : _tabController.index == 1 ? 'accepted' : 'declined'} requests',
                    style: AppTextStyles.bodyLarge,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) =>
                      _buildRequestCard(requests[index]),
                ),
    );
  }
}
