import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/electrician_provider.dart';
import '../../../models/working_hours_model.dart';
import '../../common/widgets/custom_button.dart';
import '../../../services/logger_service.dart';

class AvailabilitySettingsScreen extends StatefulWidget {
  const AvailabilitySettingsScreen({super.key});

  @override
  State<AvailabilitySettingsScreen> createState() =>
      _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState
    extends State<AvailabilitySettingsScreen> {
  bool _isLoading = false;
  List<WorkingHours>? _workingHours;
  String? _updatingDay;

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }

  Future<void> _loadWorkingHours() async {
    setState(() => _isLoading = true);

    try {
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      final workingHours = await context
          .read<ScheduleProvider>()
          .loadWorkingHours(electricianId);
      setState(() => _workingHours = workingHours);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load working hours')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateWorkingHours(
    int dayOfWeek,
    bool isEnabled,
    String? startTime,
    String? endTime,
  ) async {
    LoggerService.info('Updating working hours for day $dayOfWeek');
    LoggerService.info(
        'Current state - Enabled: $isEnabled, Start: $startTime, End: $endTime');

    // Set loading state only for this specific day
    setState(() => _updatingDay = dayOfWeek.toString());

    try {
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      LoggerService.info('Electrician ID: $electricianId');

      // Initialize working hours if null
      if (_workingHours == null) {
        _workingHours = WorkingHours.defaults(electricianId: electricianId);
      }

      // Create a copy of the working hours list
      final updatedHours = List<WorkingHours>.from(_workingHours!);

      // Find and update the specific day
      final dayIndex =
          updatedHours.indexWhere((wh) => wh.dayOfWeek == dayOfWeek);
      if (dayIndex >= 0) {
        updatedHours[dayIndex] = updatedHours[dayIndex].copyWith(
          isWorkingDay: isEnabled,
          startTime: startTime ?? '09:00',
          endTime: endTime ?? '17:00',
        );
      } else {
        // Add new working hours for this day if it doesn't exist
        updatedHours.add(WorkingHours(
          id: '', // Will be set by the database
          electricianId: electricianId,
          dayOfWeek: dayOfWeek,
          startTime: startTime ?? '09:00',
          endTime: endTime ?? '17:00',
          isWorkingDay: isEnabled,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }

      // Update the database
      final updatedWorkingHours = await context
          .read<ScheduleProvider>()
          .updateWorkingHours(electricianId, updatedHours);

      if (mounted) {
        setState(() {
          _workingHours = updatedWorkingHours;
          _updatingDay = null;
        });
      }
    } catch (e) {
      LoggerService.error('Failed to update working hours: ${e.toString()}');
      if (mounted) {
        setState(() => _updatingDay = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update working hours: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  WorkingHours? _getDaySchedule(int dayOfWeek) {
    if (_workingHours == null) {
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      _workingHours = WorkingHours.defaults(electricianId: electricianId);
    }
    return _workingHours!.firstWhere(
      (wh) => wh.dayOfWeek == dayOfWeek,
      orElse: () => WorkingHours(
        id: '',
        electricianId:
            context.read<ElectricianProvider>().getCurrentElectricianId(),
        dayOfWeek: dayOfWeek,
        startTime: '09:00',
        endTime: '17:00',
        isWorkingDay: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Widget _buildDaySettings(int dayOfWeek) {
    final schedule = _getDaySchedule(dayOfWeek);
    final isEnabled = schedule?.isWorkingDay ?? false;
    final isUpdating = _updatingDay == dayOfWeek.toString();
    final dayName = WorkingHours.getDayName(dayOfWeek);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayName,
                  style: AppTextStyles.h3,
                ),
                if (isUpdating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                else
                  Switch(
                    value: isEnabled,
                    onChanged: (value) {
                      LoggerService.info(
                          'Switch toggled to: $value for $dayName');
                      _updateWorkingHours(
                        dayOfWeek,
                        value,
                        value ? '09:00' : null,
                        value ? '17:00' : null,
                      );
                    },
                    activeColor: AppColors.accent,
                    inactiveTrackColor: Colors.grey[300],
                  ),
              ],
            ),
            if (isEnabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: int.parse(
                                    schedule?.startTime.split(':')[0] ?? '9'),
                                minute: int.parse(
                                    schedule?.startTime.split(':')[1] ?? '0'),
                              ),
                            );
                            if (time != null) {
                              _updateWorkingHours(
                                dayOfWeek,
                                true,
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                schedule?.endTime,
                              );
                            }
                          },
                          text: schedule?.startTime ?? '09:00',
                          type: ButtonType.secondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: int.parse(
                                    schedule?.endTime.split(':')[0] ?? '17'),
                                minute: int.parse(
                                    schedule?.endTime.split(':')[1] ?? '0'),
                              ),
                            );
                            if (time != null) {
                              _updateWorkingHours(
                                dayOfWeek,
                                true,
                                schedule?.startTime,
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                              );
                            }
                          },
                          text: schedule?.endTime ?? '17:00',
                          type: ButtonType.secondary,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Working Hours'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: 7,
              itemBuilder: (context, index) => _buildDaySettings(index),
            ),
    );
  }
}
