import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../widgets/primary_button.dart';
import 'contact_support_screen.dart';
import 'report_issue_screen.dart';
import 'all_faqs_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Theme(
      data: ThemeData(
        dividerColor: Colors.transparent,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          childrenPadding: const EdgeInsets.all(16),
          expandedAlignment: Alignment.topLeft,
          children: [
            Text(
              answer,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
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
          'Help Center',
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
              'How can we help you?',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 24),
            _buildSupportOption(
              title: 'Contact Support',
              subtitle: 'Get help from our support team',
              icon: Icons.headset_mic_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContactSupportScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              title: 'Report an Issue',
              subtitle: "Let us know if something's not working",
              icon: Icons.bug_report_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportIssueScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Frequently Asked Questions',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              question: 'How do I find an electrician?',
              answer: 'You can search for electricians based on your location, '
                  'service needs, and availability. Browse through profiles, '
                  'reviews, and ratings to find the right professional for your job.',
            ),
            _buildFAQItem(
              question: 'How do payments work?',
              answer: 'Payments are processed securely through our platform. '
                  'You can add multiple payment methods and pay for services '
                  'once the job is completed and you are satisfied with the work.',
            ),
            _buildFAQItem(
              question: 'What if I need to cancel a job?',
              answer: 'You can cancel a job through the app up to 24 hours '
                  'before the scheduled time without any penalty. For last-minute '
                  'cancellations, please contact support for assistance.',
            ),
            _buildFAQItem(
              question: 'How are electricians verified?',
              answer: 'All electricians on our platform undergo a thorough '
                  'verification process, including license verification, '
                  'background checks, and proof of insurance. Look for the '
                  'verified badge on their profiles.',
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllFAQsScreen(),
                  ),
                );
              },
              child: const Text('Browse All FAQs'),
            ),
          ],
        ),
      ),
    );
  }
}
