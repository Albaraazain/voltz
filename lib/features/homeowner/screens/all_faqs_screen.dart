import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class AllFAQsScreen extends StatefulWidget {
  const AllFAQsScreen({super.key});

  @override
  State<AllFAQsScreen> createState() => _AllFAQsScreenState();
}

class _AllFAQsScreenState extends State<AllFAQsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  final _faqCategories = [
    {
      'title': 'Getting Started',
      'faqs': [
        {
          'question': 'How do I create an account?',
          'answer':
              'To create an account, download our app and click "Sign Up". You can register using your email, phone number, or social media accounts. Follow the verification process to complete your registration.',
        },
        {
          'question': 'What information do I need to provide?',
          'answer':
              'You\'ll need to provide basic information including your name, contact details, and address. This helps us connect you with electricians in your area and ensure smooth communication.',
        },
        {
          'question': 'Is my personal information secure?',
          'answer':
              'Yes, we take data security seriously. All personal information is encrypted and stored securely. We never share your details without your consent and comply with all relevant data protection regulations.',
        },
      ],
    },
    {
      'title': 'Finding Electricians',
      'faqs': [
        {
          'question': 'How do I find an electrician?',
          'answer':
              'You can search for electricians based on your location, service needs, and availability. Browse through profiles, reviews, and ratings to find the right professional for your job.',
        },
        {
          'question': 'How are electricians verified?',
          'answer':
              'All electricians undergo a thorough verification process including license verification, background checks, and proof of insurance. Look for the verified badge on their profiles.',
        },
        {
          'question': 'Can I choose a specific electrician?',
          'answer':
              'Yes, you can browse electrician profiles and select one based on their expertise, ratings, and reviews. You can also save favorite electricians for future jobs.',
        },
        {
          'question': 'What if no electricians are available?',
          'answer':
              'If no electricians are immediately available, you can join a waiting list or adjust your preferred time slot. We\'ll notify you when an electrician becomes available.',
        },
      ],
    },
    {
      'title': 'Bookings & Appointments',
      'faqs': [
        {
          'question': 'How do I schedule an appointment?',
          'answer':
              'Select an electrician, choose your preferred date and time, describe your electrical needs, and confirm the booking. You\'ll receive a confirmation notification once the electrician accepts.',
        },
        {
          'question': 'Can I reschedule an appointment?',
          'answer':
              'Yes, you can reschedule through the app up to 24 hours before the scheduled time. For last-minute changes, please contact support or the electrician directly.',
        },
        {
          'question': 'What if I need to cancel?',
          'answer':
              'You can cancel a job through the app up to 24 hours before the scheduled time without any penalty. For last-minute cancellations, please contact support for assistance.',
        },
      ],
    },
    {
      'title': 'Payments & Billing',
      'faqs': [
        {
          'question': 'How do payments work?',
          'answer':
              'Payments are processed securely through our platform. You can add multiple payment methods and pay for services once the job is completed and you are satisfied with the work.',
        },
        {
          'question': 'What payment methods are accepted?',
          'answer':
              'We accept major credit/debit cards, digital wallets, and bank transfers. All payments are processed securely through our platform.',
        },
        {
          'question': 'When am I charged for services?',
          'answer':
              'Payment is typically processed after the job is completed and you\'ve approved the work. Some services may require a deposit or upfront payment, which will be clearly communicated.',
        },
        {
          'question': 'How do refunds work?',
          'answer':
              'If you\'re eligible for a refund, it will be processed to your original payment method. Refund timing depends on your payment provider, typically 5-10 business days.',
        },
      ],
    },
    {
      'title': 'Service & Quality',
      'faqs': [
        {
          'question': 'What if I\'m not satisfied with the service?',
          'answer':
              'If you\'re not satisfied, please contact support immediately. We\'ll work with you and the electrician to resolve any issues and ensure the work meets our quality standards.',
        },
        {
          'question': 'Are the services guaranteed?',
          'answer':
              'Yes, all work performed through our platform comes with a satisfaction guarantee. If any issues arise, we\'ll work to resolve them promptly.',
        },
        {
          'question': 'How do I report a problem?',
          'answer':
              'You can report issues through the app\'s "Report an Issue" feature or contact our support team directly. We\'ll investigate and respond promptly to resolve your concerns.',
        },
      ],
    },
  ];

  List<Map<String, dynamic>> get _filteredFAQs {
    if (_searchQuery.isEmpty) {
      return _faqCategories;
    }

    final query = _searchQuery.toLowerCase();
    return _faqCategories
        .map((category) {
          final filteredFaqs = (category['faqs'] as List).where((faq) {
            final question = (faq['question'] as String).toLowerCase();
            final answer = (faq['answer'] as String).toLowerCase();
            return question.contains(query) || answer.contains(query);
          }).toList();

          return {
            'title': category['title'],
            'faqs': filteredFaqs,
          };
        })
        .where((category) => (category['faqs'] as List).isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  Widget _buildCategoryChip(String title, int index) {
    final isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _filteredFAQs;
    final displayedCategory = _searchQuery.isEmpty
        ? filteredCategories[_selectedCategoryIndex]
        : filteredCategories.isNotEmpty
            ? filteredCategories[0]
            : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'FAQs',
          style: AppTextStyles.h2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Search FAQs...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 24),
                  // Category Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < _faqCategories.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          _buildCategoryChip(
                              _faqCategories[i]['title'] as String, i),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: displayedCategory == null
                ? Center(
                    child: Text(
                      'No FAQs found',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayedCategory['title'] as String,
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 16),
                        ...(displayedCategory['faqs'] as List).map(
                          (faq) => _buildFAQItem(
                            question: faq['question'] as String,
                            answer: faq['answer'] as String,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
