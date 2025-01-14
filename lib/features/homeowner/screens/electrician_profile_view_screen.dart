import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/electrician_model.dart';
import '../../../models/schedule_slot_model.dart';
import '../../../providers/database_provider.dart';
import '../widgets/availability_viewer.dart';

class ElectricianProfileViewScreen extends StatefulWidget {
  final String electricianId;

  const ElectricianProfileViewScreen({
    super.key,
    required this.electricianId,
  });

  @override
  State<ElectricianProfileViewScreen> createState() =>
      _ElectricianProfileViewScreenState();
}

class _ElectricianProfileViewScreenState
    extends State<ElectricianProfileViewScreen> {
  bool _isLoading = false;

  void _handleSlotSelected(ScheduleSlot slot) {
    Navigator.pushNamed(
      context,
      '/book_appointment',
      arguments: {
        'electricianId': widget.electricianId,
        'slot': slot,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Book Appointment',
          style: AppTextStyles.h2,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AvailabilityViewer(
              electricianId: widget.electricianId,
              onSlotSelected: _handleSlotSelected,
            ),
    );
  }
}
