import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/calendar_sync_model.dart';
import '../../../providers/calendar_sync_provider.dart';
import '../../../providers/electrician_provider.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/loading_indicator.dart';

class CalendarSyncScreen extends StatefulWidget {
  const CalendarSyncScreen({super.key});

  @override
  State<CalendarSyncScreen> createState() => _CalendarSyncScreenState();
}

class _CalendarSyncScreenState extends State<CalendarSyncScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSyncedCalendars();
  }

  Future<void> _loadSyncedCalendars() async {
    setState(() => _isLoading = true);

    try {
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      await context
          .read<CalendarSyncProvider>()
          .loadSyncedCalendars(electricianId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load synced calendars')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSync() async {
    setState(() => _isLoading = true);

    try {
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      await context
          .read<CalendarSyncProvider>()
          .syncAllCalendars(electricianId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calendars synced successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync calendars')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addCalendarSync(String provider) async {
    // TODO: Implement OAuth flow for each provider
    switch (provider) {
      case 'google':
        // Implement Google Calendar OAuth
        break;
      case 'outlook':
        // Implement Outlook Calendar OAuth
        break;
      case 'apple':
        // Implement Apple Calendar permissions
        break;
    }
  }

  Future<void> _removeCalendarSync(String syncId) async {
    try {
      await context.read<CalendarSyncProvider>().removeCalendarSync(syncId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calendar removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove calendar')),
        );
      }
    }
  }

  Widget _buildCalendarCard(CalendarSync sync) {
    final providerIcon = switch (sync.provider) {
      'google' => Icons.calendar_month,
      'outlook' => Icons.calendar_today,
      'apple' => Icons.calendar_view_month,
      _ => Icons.calendar_month,
    };

    final providerName = switch (sync.provider) {
      'google' => 'Google Calendar',
      'outlook' => 'Outlook Calendar',
      'apple' => 'Apple Calendar',
      _ => 'Unknown Provider',
    };

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(providerIcon, color: AppColors.accent),
                const SizedBox(width: 12),
                Text(
                  providerName,
                  style: AppTextStyles.h3,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeCalendarSync(sync.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (sync.lastSyncedAt != null) ...[
              Text(
                'Last synced:',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatDateTime(sync.lastSyncedAt!),
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final syncProvider = context.watch<CalendarSyncProvider>();
    final syncedCalendars = syncProvider.syncedCalendars;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Calendar Sync',
          style: AppTextStyles.h2,
        ),
        actions: [
          if (syncedCalendars.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _isLoading ? null : _handleSync,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : syncedCalendars.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No calendars synced',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a calendar to sync your schedule',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: syncedCalendars.length,
                  itemBuilder: (context, index) =>
                      _buildCalendarCard(syncedCalendars[index]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add Calendar',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _addCalendarSync('google');
                    },
                    text: 'Google Calendar',
                    type: ButtonType.secondary,
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _addCalendarSync('outlook');
                    },
                    text: 'Outlook Calendar',
                    type: ButtonType.secondary,
                  ),
                  const SizedBox(height: 8),
                  CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _addCalendarSync('apple');
                    },
                    text: 'Apple Calendar',
                    type: ButtonType.secondary,
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.surface),
      ),
    );
  }
}
