import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/direct_request_provider.dart';
import '../../../providers/electrician_provider.dart';
import '../../../models/direct_request_model.dart';
import '../../common/widgets/custom_button.dart';

class IncomingRequestsScreen extends StatefulWidget {
  const IncomingRequestsScreen({super.key});

  @override
  State<IncomingRequestsScreen> createState() => _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState extends State<IncomingRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _selectedFilter = DirectRequest.STATUS_PENDING;

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
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      await context
          .read<DirectRequestProvider>()
          .loadElectricianRequests(electricianId);
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

  Future<void> _handleRequestAction(
      DirectRequest request, String action) async {
    try {
      setState(() => _isLoading = true);

      switch (action) {
        case 'accept':
          await context.read<DirectRequestProvider>().updateRequestStatus(
                requestId: request.id,
                status: DirectRequest.STATUS_ACCEPTED,
              );
          break;
        case 'decline':
          final reason = await _showDeclineDialog();
          if (reason != null) {
            await context.read<DirectRequestProvider>().updateRequestStatus(
                  requestId: request.id,
                  status: DirectRequest.STATUS_DECLINED,
                  declineReason: reason,
                );
          }
          break;
        case 'reschedule':
          final result = await _showRescheduleDialog();
          if (result != null) {
            await context.read<DirectRequestProvider>().proposeReschedule(
                  requestId: request.id,
                  newDate: result['date'],
                  newTime: result['time'],
                  message: result['message'],
                );
          }
          break;
        case 'start':
          await context.read<DirectRequestProvider>().startService(
                requestId: request.id,
              );
          break;
        case 'complete':
          await context.read<DirectRequestProvider>().completeService(
                requestId: request.id,
              );
          break;
        case 'cancel':
          final reason = await _showCancelDialog();
          if (reason != null) {
            await context.read<DirectRequestProvider>().cancelRequest(
                  requestId: request.id,
                  reason: reason,
                  isCancelledByHomeowner: false,
                );
          }
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${_getActionText(action)}'),
            backgroundColor: _getActionColor(action),
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

  String _getActionText(String action) {
    switch (action) {
      case 'accept':
        return 'accepted';
      case 'decline':
        return 'declined';
      case 'reschedule':
        return 'rescheduled';
      case 'start':
        return 'started';
      case 'complete':
        return 'completed';
      case 'cancel':
        return 'cancelled';
      default:
        return 'updated';
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'accept':
      case 'complete':
        return Colors.green;
      case 'decline':
      case 'cancel':
        return Colors.red;
      case 'reschedule':
        return Colors.blue;
      case 'start':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<String?> _showDeclineDialog() async {
    final reasonController = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for declining',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, reasonController.text.trim()),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
    return result?.isNotEmpty == true ? result : null;
  }

  Future<String?> _showCancelDialog() async {
    final reasonController = TextEditingController();
    final result = await showDialog<String?>(
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
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, reasonController.text.trim()),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result?.isNotEmpty == true ? result : null;
  }

  Future<Map<String, dynamic>?> _showRescheduleDialog() async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Propose New Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'Date: ${selectedDate.toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (date != null) {
                    setState(() => selectedDate = date);
                  }
                },
              ),
              ListTile(
                title: Text(
                  'Time: ${selectedTime.format(context)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() => selectedTime = time);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message to homeowner',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Propose'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      return {
        'date': selectedDate,
        'time':
            '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
        'message': messageController.text.trim(),
      };
    }
    return null;
  }

  Widget _buildRequestCard(DirectRequest request) {
    final isPending = request.status == DirectRequest.STATUS_PENDING;
    final isAccepted = request.status == DirectRequest.STATUS_ACCEPTED;
    final isInProgress = request.status == DirectRequest.STATUS_IN_PROGRESS;

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
                    color: _getStatusColor(request.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.statusText,
                    style: TextStyle(color: _getStatusColor(request.status)),
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
            const SizedBox(height: 16),
            if (isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _handleRequestAction(request, 'decline'),
                    child: const Text('Decline'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () =>
                        _handleRequestAction(request, 'reschedule'),
                    child: const Text('Propose New Time'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleRequestAction(request, 'accept'),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            if (isAccepted)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _handleRequestAction(request, 'cancel'),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleRequestAction(request, 'start'),
                    child: const Text('Start Service'),
                  ),
                ],
              ),
            if (isInProgress)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleRequestAction(request, 'complete'),
                    child: const Text('Complete Service'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case DirectRequest.STATUS_PENDING:
        return Colors.orange;
      case DirectRequest.STATUS_ACCEPTED:
        return Colors.green;
      case DirectRequest.STATUS_DECLINED:
        return Colors.red;
      case DirectRequest.STATUS_CANCELLED:
        return Colors.grey;
      case DirectRequest.STATUS_RESCHEDULED:
        return Colors.blue;
      case DirectRequest.STATUS_IN_PROGRESS:
        return Colors.purple;
      case DirectRequest.STATUS_COMPLETED:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Requests'),
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
          ? const Center(child: CircularProgressIndicator())
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
