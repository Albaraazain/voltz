import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/job_model.dart';
import '../../../providers/job_provider.dart';
import '../../common/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  // Standard spacing constants
  static const double kPagePadding = 20.0;
  static const double kCardPadding = 24.0;
  static const double kSpacingXS = 8.0;
  static const double kSpacingS = 12.0;
  static const double kSpacingM = 16.0;
  static const double kSpacingL = 24.0;
  static const double kSpacingXL = 32.0;
  static const double kBorderRadius = 16.0;
  static const double kCardElevation = 2.0;
  static const double kIconSize = 22.0;

  const JobDetailsScreen({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final dateFormat = DateFormat('MMM d, y - h:mm a');
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background ?? Colors.grey[50],
      appBar: AppBar(
        title: Text('Job Details', style: AppTextStyles.h3),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.textPrimary, size: kIconSize),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              kPagePadding,
              kSpacingS,
              kPagePadding,
              kSpacingXL * 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: kSpacingL),
                  padding: const EdgeInsets.symmetric(
                    vertical: kSpacingM,
                    horizontal: kCardPadding,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _getStatusColor(job.status).withOpacity(0.9),
                        _getStatusColor(job.status).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(kBorderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(job.status).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(kSpacingS),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(kBorderRadius - 4),
                        ),
                        child: Icon(
                          _getStatusIcon(job.status),
                          color: Colors.white,
                          size: kIconSize,
                        ),
                      ),
                      const SizedBox(width: kSpacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusText(job.status),
                              style: AppTextStyles.h3.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: kSpacingXS),
                            Text(
                              'Last updated: ${dateFormat.format(job.createdAt)}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Job Title and Price Card
                Card(
                  elevation: kCardElevation,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(kCardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    job.title,
                                    style: AppTextStyles.h2.copyWith(
                                      fontSize: 24,
                                      height: 1.2,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: kSpacingS),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: kSpacingXS),
                                      Text(
                                        dateFormat.format(job.date),
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: kSpacingM,
                                vertical: kSpacingS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(kBorderRadius),
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Price',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.accent,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '\$${job.price.toStringAsFixed(2)}',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.accent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: kSpacingL),

                // Description Card
                Card(
                  elevation: kCardElevation,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kBorderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(kCardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.description_outlined,
                              size: kIconSize,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: kSpacingS),
                            Text(
                              'Job Description',
                              style: AppTextStyles.h3.copyWith(
                                fontSize: 18,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: kSpacingM),
                          child: Divider(height: 1),
                        ),
                        Text(
                          job.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.6,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: kSpacingL),

                // Client Information Card
                if (job.homeowner != null)
                  Card(
                    elevation: kCardElevation,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(kCardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: kIconSize,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: kSpacingS),
                              Text(
                                'Client Information',
                                style: AppTextStyles.h3.copyWith(
                                  fontSize: 18,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: kSpacingL),
                          _buildClientInfoRow(
                            Icons.badge_outlined,
                            'Name',
                            job.homeowner!.profile.name,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: kSpacingM),
                            child: Divider(height: 1),
                          ),
                          _buildClientInfoRow(
                            Icons.email_outlined,
                            'Email',
                            job.homeowner!.profile.email,
                          ),
                          if (job.homeowner!.phone != null) ...[
                            const Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: kSpacingM),
                              child: Divider(height: 1),
                            ),
                            _buildClientInfoRow(
                              Icons.phone_outlined,
                              'Phone',
                              job.homeowner!.phone!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Action Buttons
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                kPagePadding,
                kSpacingM,
                kPagePadding,
                kSpacingM + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: job.status == Job.STATUS_PENDING
                    ? Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              onPressed: () async {
                                try {
                                  await jobProvider.updateJobStatus(
                                    job.id,
                                    Job.STATUS_CANCELLED,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                              text: 'Decline',
                              type: ButtonType.secondary,
                            ),
                          ),
                          const SizedBox(width: kSpacingM),
                          Expanded(
                            child: CustomButton(
                              onPressed: () async {
                                try {
                                  await jobProvider.updateJobStatus(
                                    job.id,
                                    Job.STATUS_IN_PROGRESS,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                              text: 'Accept Job',
                              type: ButtonType.primary,
                            ),
                          ),
                        ],
                      )
                    : job.status == Job.STATUS_IN_PROGRESS
                        ? CustomButton(
                            onPressed: () async {
                              try {
                                await jobProvider.updateJobStatus(
                                  job.id,
                                  Job.STATUS_COMPLETED,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            text: 'Mark as Completed',
                            type: ButtonType.primary,
                          )
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Job.STATUS_PENDING:
        return AppColors.warning;
      case Job.STATUS_IN_PROGRESS:
        return AppColors.primary;
      case Job.STATUS_COMPLETED:
        return AppColors.success;
      case Job.STATUS_CANCELLED:
        return AppColors.error;
      default:
        return AppColors.textLight;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case Job.STATUS_PENDING:
        return Icons.schedule;
      case Job.STATUS_IN_PROGRESS:
        return Icons.engineering;
      case Job.STATUS_COMPLETED:
        return Icons.check_circle;
      case Job.STATUS_CANCELLED:
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case Job.STATUS_PENDING:
        return 'Pending Confirmation';
      case Job.STATUS_IN_PROGRESS:
        return 'In Progress';
      case Job.STATUS_COMPLETED:
        return 'Completed';
      case Job.STATUS_CANCELLED:
        return 'Cancelled';
      default:
        return status;
    }
  }

  Widget _buildClientInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(kSpacingS),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(kBorderRadius - 4),
          ),
          child: Icon(
            icon,
            size: kIconSize - 2,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: kSpacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
