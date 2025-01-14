import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../common/widgets/custom_button.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isLoading = false;
  late NotificationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = NotificationSettings();
    _loadSettings();
  }

  void _loadSettings() {
    // TODO: Load notification settings from database
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Save notification settings to database
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update notification settings')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Notification Settings', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push Notifications
            Text('Push Notifications', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _buildNotificationSection(
              title: 'New Job Requests',
              subtitle:
                  'Get notified when homeowners send you new job requests',
              value: _settings.newJobRequests,
              onChanged: (value) {
                setState(() => _settings.newJobRequests = value);
              },
            ),
            _buildNotificationSection(
              title: 'Job Updates',
              subtitle:
                  'Get notified when there are updates to your scheduled jobs',
              value: _settings.jobUpdates,
              onChanged: (value) {
                setState(() => _settings.jobUpdates = value);
              },
            ),
            _buildNotificationSection(
              title: 'Messages',
              subtitle: 'Get notified when you receive new messages',
              value: _settings.messages,
              onChanged: (value) {
                setState(() => _settings.messages = value);
              },
            ),
            const SizedBox(height: 32),

            // Email Notifications
            Text('Email Notifications', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _buildNotificationSection(
              title: 'Weekly Summary',
              subtitle: 'Receive a weekly summary of your jobs and earnings',
              value: _settings.weeklySummary,
              onChanged: (value) {
                setState(() => _settings.weeklySummary = value);
              },
            ),
            _buildNotificationSection(
              title: 'Payment Updates',
              subtitle: 'Get notified about payments and transfers',
              value: _settings.paymentUpdates,
              onChanged: (value) {
                setState(() => _settings.paymentUpdates = value);
              },
            ),
            _buildNotificationSection(
              title: 'Promotions',
              subtitle: 'Receive updates about promotions and features',
              value: _settings.promotions,
              onChanged: (value) {
                setState(() => _settings.promotions = value);
              },
            ),
            const SizedBox(height: 32),

            // Quiet Hours
            Text('Quiet Hours', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Enable Quiet Hours',
                                  style: AppTextStyles.bodyLarge),
                              Text(
                                'Mute notifications during specific hours',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _settings.quietHoursEnabled,
                          onChanged: (value) {
                            setState(() => _settings.quietHoursEnabled = value);
                          },
                          activeColor: AppColors.accent,
                        ),
                      ],
                    ),
                    if (_settings.quietHoursEnabled) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Start Time',
                                    style: AppTextStyles.bodyMedium),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectTime(true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _formatTimeOfDay(
                                          _settings.quietHoursStart),
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('End Time',
                                    style: AppTextStyles.bodyMedium),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _selectTime(false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: AppColors.border),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _formatTimeOfDay(_settings.quietHoursEnd),
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            CustomButton(
              onPressed: _isLoading ? null : _saveSettings,
              text: _isLoading ? 'Saving...' : 'Save Changes',
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          isStart ? _settings.quietHoursStart : _settings.quietHoursEnd,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _settings.quietHoursStart = picked;
        } else {
          _settings.quietHoursEnd = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class NotificationSettings {
  bool newJobRequests;
  bool jobUpdates;
  bool messages;
  bool weeklySummary;
  bool paymentUpdates;
  bool promotions;
  bool quietHoursEnabled;
  TimeOfDay quietHoursStart;
  TimeOfDay quietHoursEnd;

  NotificationSettings({
    this.newJobRequests = true,
    this.jobUpdates = true,
    this.messages = true,
    this.weeklySummary = true,
    this.paymentUpdates = true,
    this.promotions = false,
    this.quietHoursEnabled = false,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  })  : quietHoursStart =
            quietHoursStart ?? const TimeOfDay(hour: 22, minute: 0),
        quietHoursEnd = quietHoursEnd ?? const TimeOfDay(hour: 7, minute: 0);
}
