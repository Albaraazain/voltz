import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  Widget _buildSection({
    required String title,
    required List<String> paragraphs,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 16),
        ...paragraphs.map((paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                paragraph,
                style: AppTextStyles.bodyMedium,
              ),
            )),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          title: Text(
            'Terms & Privacy',
            style: AppTextStyles.h2,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.accent,
            tabs: const [
              Tab(text: 'Terms of Service'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Terms of Service Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms of Service',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: March 24, 2024',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '1. Acceptance of Terms',
                    paragraphs: [
                      'By accessing and using the Voltz app, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.',
                      'These terms apply to all users of the platform, including homeowners and electricians.',
                    ],
                  ),
                  _buildSection(
                    title: '2. User Responsibilities',
                    paragraphs: [
                      'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
                      'You agree to provide accurate and complete information when creating an account and to update this information as needed.',
                    ],
                  ),
                  _buildSection(
                    title: '3. Service Usage',
                    paragraphs: [
                      'Our platform connects homeowners with qualified electricians. We do not perform electrical services ourselves.',
                      'While we verify electricians on our platform, we are not responsible for the quality of work performed.',
                    ],
                  ),
                  _buildSection(
                    title: '4. Payments',
                    paragraphs: [
                      'All payments are processed securely through our platform. Service fees will be clearly displayed before confirming any transaction.',
                      'Cancellation policies and refund terms are subject to the specific circumstances of each booking.',
                    ],
                  ),
                ],
              ),
            ),
            // Privacy Policy Tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last updated: March 24, 2024',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: '1. Information We Collect',
                    paragraphs: [
                      'We collect information you provide directly to us, including name, contact information, and payment details.',
                      'We also collect usage data and location information to improve our services.',
                    ],
                  ),
                  _buildSection(
                    title: '2. How We Use Your Information',
                    paragraphs: [
                      'We use your information to provide and improve our services, process payments, and communicate with you.',
                      'Your information helps us match you with appropriate service providers and ensure platform safety.',
                    ],
                  ),
                  _buildSection(
                    title: '3. Information Sharing',
                    paragraphs: [
                      'We share your information with service providers only as necessary to fulfill service requests.',
                      'We may share anonymized data for analytics and improvement purposes.',
                    ],
                  ),
                  _buildSection(
                    title: '4. Data Security',
                    paragraphs: [
                      'We implement appropriate security measures to protect your personal information.',
                      'While we take precautions, no method of transmission over the internet is 100% secure.',
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
