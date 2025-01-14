import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/electrician_provider.dart';
import '../../../models/working_hours_model.dart';
import '../../common/widgets/custom_button.dart';

class AvailabilitySettingsScreen extends StatefulWidget {
  const AvailabilitySettingsScreen({super.key});

  @override
  State<AvailabilitySettingsScreen> createState() =>
      _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState
    extends State<AvailabilitySettingsScreen> {
  bool _isLoading = false;
  WorkingHours? _workingHours;

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
    String day,
    bool isEnabled,
    String? startTime,
    String? endTime,
  ) async {
    try {
      setState(() => _isLoading = true);

      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();

      // Create updated schedule based on current state
      final updatedSchedule = _workingHours?.toJson() ?? {};
      if (isEnabled && startTime != null && endTime != null) {
        updatedSchedule[day.toLowerCase()] = {
          'start': startTime,
          'end': endTime,
        };
      } else {
        updatedSchedule[day.toLowerCase()] = null;
      }

      final workingHours = await context
          .read<ScheduleProvider>()
          .updateWorkingHours(electricianId, updatedSchedule);

      setState(() => _workingHours = workingHours);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Working hours updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update working hours')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  DaySchedule? _getDaySchedule(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return _workingHours?.monday;
      case 'tuesday':
        return _workingHours?.tuesday;
      case 'wednesday':
        return _workingHours?.wednesday;
      case 'thursday':
        return _workingHours?.thursday;
      case 'friday':
        return _workingHours?.friday;
      case 'saturday':
        return _workingHours?.saturday;
      case 'sunday':
        return _workingHours?.sunday;
      default:
        return null;
    }
  }

  Widget _buildDaySettings(String dayName) {
    final schedule = _getDaySchedule(dayName);
    final isEnabled = schedule != null;

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
                Switch(
                  value: isEnabled,
                  onChanged: (value) => _updateWorkingHours(
                    dayName,
                    value,
                    value ? '09:00' : null,
                    value ? '17:00' : null,
                  ),
                ),
              ],
            ),
            if (isEnabled && schedule != null) ...[
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
                                    schedule.start?.split(':')[0] ?? '9'),
                                minute: int.parse(
                                    schedule.start?.split(':')[1] ?? '0'),
                              ),
                            );
                            if (time != null) {
                              _updateWorkingHours(
                                dayName,
                                true,
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                schedule.end,
                              );
                            }
                          },
                          text: schedule.start ?? '09:00',
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
                                    schedule.end?.split(':')[0] ?? '17'),
                                minute: int.parse(
                                    schedule.end?.split(':')[1] ?? '0'),
                              ),
                            );
                            if (time != null) {
                              _updateWorkingHours(
                                dayName,
                                true,
                                schedule.start,
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                              );
                            }
                          },
                          text: schedule.end ?? '17:00',
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Availability Settings',
          style: AppTextStyles.h2,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildDaySettings('Monday'),
                _buildDaySettings('Tuesday'),
                _buildDaySettings('Wednesday'),
                _buildDaySettings('Thursday'),
                _buildDaySettings('Friday'),
                _buildDaySettings('Saturday'),
                _buildDaySettings('Sunday'),
              ],
            ),
    );
  }
}
