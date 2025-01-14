import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/electrician_provider.dart';
import '../../../models/reschedule_request_model.dart';
import '../../common/widgets/custom_button.dart';

class RescheduleManagementScreen extends StatefulWidget {
  const RescheduleManagementScreen({super.key});

  @override
  State<RescheduleManagementScreen> createState() =>
      _RescheduleManagementScreenState();
}

class _RescheduleManagementScreenState extends State<RescheduleManagementScreen>
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
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      await context
          .read<ScheduleProvider>()
          .loadRescheduleRequests(electricianId);
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

  Future<void> _proposeNewTime(String requestId) async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (timeOfDay != null && mounted) {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 90)),
      );

      if (date != null && mounted) {
        try {
          setState(() => _isLoading = true);

          await context.read<ScheduleProvider>().proposeNewTime(
                requestId,
                date,
                '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}',
              );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('New time proposed successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to propose new time')),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      }
    }
  }

  Widget _buildRequestCard(RescheduleRequest request) {
    final isPending = request.status == 'PENDING';

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
                    color: request.status == 'PENDING'
                        ? Colors.orange
                        : request.status == 'ACCEPTED'
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
                    onPressed: () => _proposeNewTime(request.id),
                    text: 'Propose New Time',
                    type: ButtonType.secondary,
                  ),
                  const SizedBox(width: 8),
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
          ? const Center(child: CircularProgressIndicator())
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
