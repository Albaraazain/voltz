import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../models/electrician_model.dart';
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
  late WorkingHours _workingHours;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }

  void _loadWorkingHours() {
    final electrician =
        context.read<DatabaseProvider>().electricians.firstWhere(
              (e) =>
                  e.profile.id ==
                  context.read<DatabaseProvider>().currentProfile?.id,
            );
    setState(() {
      _workingHours = electrician.workingHours;
    });
  }

  Future<void> _saveWorkingHours() async {
    setState(() => _isLoading = true);

    try {
      final dbProvider = context.read<DatabaseProvider>();
      final currentElectrician = dbProvider.electricians.firstWhere(
        (e) => e.profile.id == dbProvider.currentProfile?.id,
      );

      final updatedElectrician = currentElectrician.copyWith(
        workingHours: _workingHours,
      );

      await dbProvider.updateElectricianProfile(updatedElectrician);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save availability settings')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectTime(String day, bool isStart) async {
    final currentSchedule = _workingHours.schedule[day];
    final currentTime = isStart ? currentSchedule?.start : currentSchedule?.end;

    final TimeOfDay initialTime = currentTime != null
        ? TimeOfDay(
            hour: int.parse(currentTime.split(':')[0]),
            minute: int.parse(currentTime.split(':')[1]),
          )
        : const TimeOfDay(hour: 9, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      setState(() {
        final newSchedule =
            Map<String, DaySchedule?>.from(_workingHours.schedule);
        final currentDaySchedule = newSchedule[day];

        if (currentDaySchedule == null) {
          newSchedule[day] = DaySchedule(
            start: isStart ? formattedTime : '17:00',
            end: isStart ? '17:00' : formattedTime,
          );
        } else {
          newSchedule[day] = DaySchedule(
            start: isStart ? formattedTime : currentDaySchedule.start,
            end: isStart ? currentDaySchedule.end : formattedTime,
          );
        }

        _workingHours = WorkingHours(schedule: newSchedule);
      });
    }
  }

  Widget _buildDaySchedule(String day, String label) {
    final schedule = _workingHours.schedule[day];
    final isEnabled = schedule != null;

    return Column(
      children: [
        SwitchListTile(
          value: isEnabled,
          onChanged: (value) {
            setState(() {
              final newSchedule =
                  Map<String, DaySchedule?>.from(_workingHours.schedule);
              newSchedule[day] = value
                  ? const DaySchedule(start: '09:00', end: '17:00')
                  : null;
              _workingHours = WorkingHours(schedule: newSchedule);
            });
          },
          title: Text(label, style: AppTextStyles.bodyMedium),
          activeColor: AppColors.accent,
        ),
        if (isEnabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Time',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectTime(day, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            schedule?.start ?? '09:00',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
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
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectTime(day, false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            schedule?.end ?? '17:00',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
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
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Working Days & Hours', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          _buildDaySchedule('monday', 'Monday'),
          _buildDaySchedule('tuesday', 'Tuesday'),
          _buildDaySchedule('wednesday', 'Wednesday'),
          _buildDaySchedule('thursday', 'Thursday'),
          _buildDaySchedule('friday', 'Friday'),
          _buildDaySchedule('saturday', 'Saturday'),
          _buildDaySchedule('sunday', 'Sunday'),
          const SizedBox(height: 32),
          CustomButton(
            onPressed: _isLoading ? null : _saveWorkingHours,
            text: _isLoading ? 'Saving...' : 'Save Changes',
          ),
        ],
      ),
    );
  }
}
