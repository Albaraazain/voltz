import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/electrician_model.dart';
import '../../../models/schedule_slot_model.dart';
import '../../../providers/database_provider.dart';
import '../widgets/availability_viewer.dart';
import '../../../services/logger_service.dart';

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
  final bool _isLoading = false;

  void _handleSlotSelected(ScheduleSlot slot) async {
    LoggerService.info('Attempting to navigate to book appointment screen');
    LoggerService.debug('Slot details before navigation:\n'
        'ID: ${slot.id}\n'
        'Date: ${slot.date}\n'
        'Time: ${slot.startTime} - ${slot.endTime}\n'
        'Status: ${slot.status}');

    try {
      final result = await Navigator.pushNamed(
        context,
        '/book_appointment',
        arguments: {
          'electricianId': widget.electricianId,
          'slot': slot.toJson(),
        },
      );

      LoggerService.debug('Navigation result: $result');
      if (result == true) {
        LoggerService.info('Appointment booked successfully');
        // Handle successful booking
      }
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to navigate to book appointment screen: ${e.toString()}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open booking screen: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
