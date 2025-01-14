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
  String _selectedFilter = 'all';

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

      await context.read<DirectRequestProvider>().updateRequestStatus(
            request.id,
            action == 'accept'
                ? DirectRequest.STATUS_ACCEPTED
                : DirectRequest.STATUS_DECLINED,
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

  Widget _buildRequestCard(DirectRequest request) {
    final isPending = request.status == DirectRequest.STATUS_PENDING;

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
                  'Job Request',
                  style: AppTextStyles.h3,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: request.status == DirectRequest.STATUS_PENDING
                        ? Colors.orange
                        : request.status == DirectRequest.STATUS_ACCEPTED
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
              'Preferred Date: ${request.preferredDate}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Preferred Time: ${request.preferredTime}',
              style: AppTextStyles.bodyMedium,
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    onPressed: () => _handleRequestAction(request, 'decline'),
                    text: 'Decline',
                    type: ButtonType.secondary,
                  ),
                  const SizedBox(width: 16),
                  CustomButton(
                    onPressed: () => _handleRequestAction(request, 'accept'),
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
    final requests = _selectedFilter == DirectRequest.STATUS_PENDING
        ? context.watch<DirectRequestProvider>().pendingRequests
        : _selectedFilter == DirectRequest.STATUS_ACCEPTED
            ? context.watch<DirectRequestProvider>().acceptedRequests
            : context.watch<DirectRequestProvider>().declinedRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Incoming Requests',
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
          onTap: (index) {
            setState(() {
              _selectedFilter = index == 0
                  ? DirectRequest.STATUS_PENDING
                  : index == 1
                      ? DirectRequest.STATUS_ACCEPTED
                      : DirectRequest.STATUS_DECLINED;
            });
            _loadRequests();
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? Center(
                  child: Text(
                    'No requests found',
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
