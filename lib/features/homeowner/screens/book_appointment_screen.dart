import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/services/logger_service.dart';
import '../../../models/schedule_slot_model.dart';
import '../../../providers/database_provider.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String electricianId;
  final ScheduleSlot? selectedSlot;

  const BookAppointmentScreen({
    super.key,
    required this.electricianId,
    this.selectedSlot,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  ScheduleSlot? _selectedSlot;
  final _dateFormat = DateFormat('EEEE, MMMM d, y');

  @override
  void initState() {
    super.initState();
    _selectedSlot = widget.selectedSlot;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectSlot() async {
    final result = await Navigator.pushNamed(
      context,
      '/select_slot',
      arguments: {
        'electricianId': widget.electricianId,
      },
    );

    if (result is ScheduleSlot && mounted) {
      setState(() => _selectedSlot = result);
    }
  }

  Future<void> _bookAppointment() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a description for your appointment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      LoggerService.info('Attempting to book appointment');
      LoggerService.debug('Booking details:\n'
          'Electrician ID: ${widget.electricianId}\n'
          'Slot ID: ${_selectedSlot!.id}\n'
          'Description: ${_descriptionController.text}');

      final databaseProvider = context.read<DatabaseProvider>();
      final homeownerId = databaseProvider.getCurrentHomeownerId();

      await databaseProvider.bookAppointment(
        electricianId: widget.electricianId,
        homeownerId: homeownerId,
        slotId: _selectedSlot!.id,
        description: _descriptionController.text.trim(),
      );

      LoggerService.info('Appointment booked successfully');

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      LoggerService.error('Failed to book appointment: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final electrician = context
        .read<DatabaseProvider>()
        .electricians
        .firstWhere((e) => e.id == widget.electricianId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Book Appointment',
          style: AppTextStyles.h2,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Electrician Info
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: electrician.profileImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              electrician.profileImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: AppColors.accent,
                            size: 32,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          electrician.profile.name,
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              electrician.rating.toStringAsFixed(1),
                              style: AppTextStyles.bodyMedium,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${electrician.jobsCompleted} jobs',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Time Slot',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  if (_selectedSlot != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _dateFormat.format(_selectedSlot!.date),
                                  style: AppTextStyles.bodyLarge,
                                ),
                                Text(
                                  '${_selectedSlot!.startTime} - ${_selectedSlot!.endTime}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _selectSlot,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    )
                  else
                    OutlinedButton(
                      onPressed: _selectSlot,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Select Time Slot'),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Describe your electrical needs...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _bookAppointment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Book Appointment'),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'or',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/direct_request',
                        arguments: {
                          'electricianId': widget.electricianId,
                          'electricianName': electrician.profile.name,
                        },
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Request Custom Time'),
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
