import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../widgets/primary_button.dart';

// Define valid contact methods to match database enum
const validContactMethods = ['email', 'phone', 'sms'];

class ContactPreferenceScreen extends StatefulWidget {
  const ContactPreferenceScreen({super.key});

  @override
  State<ContactPreferenceScreen> createState() =>
      _ContactPreferenceScreenState();
}

class _ContactPreferenceScreenState extends State<ContactPreferenceScreen> {
  String _selectedMethod = 'email';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final homeowner = context.read<DatabaseProvider>().currentHomeowner;
    if (homeowner != null) {
      final method = homeowner.preferredContactMethod;
      // Ensure we only use valid enum values
      _selectedMethod = validContactMethods.contains(method) ? method : 'email';
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);

    try {
      final databaseProvider = context.read<DatabaseProvider>();
      await databaseProvider.updateHomeownerContactPreference(_selectedMethod);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Contact preference saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving contact preference: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPreferenceOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return RadioListTile(
      value: value,
      groupValue: _selectedMethod,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedMethod = value);
        }
      },
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
      secondary: Icon(
        icon,
        color: _selectedMethod == value
            ? AppColors.accent
            : AppColors.textSecondary,
      ),
      activeColor: AppColors.accent,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedMethod == value ? AppColors.accent : AppColors.border,
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
          'Contact Preference',
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
              'How would you like to be contacted?',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your preferred method of communication for job updates and notifications.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 24),
            _buildPreferenceOption(
              value: 'email',
              title: 'Email',
              subtitle: 'Receive updates in your inbox',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _buildPreferenceOption(
              value: 'phone',
              title: 'Phone',
              subtitle: 'Get notified via phone calls',
              icon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            _buildPreferenceOption(
              value: 'sms',
              title: 'SMS',
              subtitle: 'Receive text message updates',
              icon: Icons.message_outlined,
            ),
            const SizedBox(height: 48),
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
