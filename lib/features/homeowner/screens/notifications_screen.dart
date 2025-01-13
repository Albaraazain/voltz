import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../widgets/primary_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;
  bool _jobUpdates = true;
  bool _newMessages = true;
  bool _paymentAlerts = true;
  bool _promotions = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final homeowner = context.read<DatabaseProvider>().currentHomeowner;
    if (homeowner != null) {
      setState(() {
        _jobUpdates = homeowner.notificationJobUpdates;
        _newMessages = homeowner.notificationMessages;
        _paymentAlerts = homeowner.notificationPayments;
        _promotions = homeowner.notificationPromotions;
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      await context
          .read<DatabaseProvider>()
          .updateHomeownerNotificationPreferences(
            jobUpdates: _jobUpdates,
            messages: _newMessages,
            payments: _paymentAlerts,
            promotions: _promotions,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification preferences saved successfully'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preferences: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildNotificationOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall,
        ),
        activeColor: AppColors.accent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Notifications',
          style: AppTextStyles.h2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Preferences',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose which notifications you want to receive.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            _buildNotificationOption(
              title: 'Job Updates',
              subtitle: 'Get notified about changes to your jobs',
              value: _jobUpdates,
              onChanged: (value) => setState(() => _jobUpdates = value),
            ),
            _buildNotificationOption(
              title: 'New Messages',
              subtitle: 'Receive notifications for new messages',
              value: _newMessages,
              onChanged: (value) => setState(() => _newMessages = value),
            ),
            _buildNotificationOption(
              title: 'Payment Alerts',
              subtitle: 'Get notified about payments and transactions',
              value: _paymentAlerts,
              onChanged: (value) => setState(() => _paymentAlerts = value),
            ),
            _buildNotificationOption(
              title: 'Promotions & Tips',
              subtitle: 'Receive updates about promotions and maintenance tips',
              value: _promotions,
              onChanged: (value) => setState(() => _promotions = value),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              onPressed: _isLoading ? null : _saveChanges,
              isLoading: _isLoading,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
