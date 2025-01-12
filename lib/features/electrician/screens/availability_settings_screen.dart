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

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _workingHours.startTime : _workingHours.endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _workingHours = _workingHours.copyWith(startTime: picked);
        } else {
          _workingHours = _workingHours.copyWith(endTime: picked);
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
          // Working Days
          Text('Working Days', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          _buildDayToggle('Monday', 0),
          _buildDayToggle('Tuesday', 1),
          _buildDayToggle('Wednesday', 2),
          _buildDayToggle('Thursday', 3),
          _buildDayToggle('Friday', 4),
          _buildDayToggle('Saturday', 5),
          _buildDayToggle('Sunday', 6),

          const SizedBox(height: 32),

          // Working Hours
          Text('Working Hours', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Row(
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
                      onTap: () => _selectTime(true),
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
                          _formatTimeOfDay(_workingHours.startTime),
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
                      onTap: () => _selectTime(false),
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
                          _formatTimeOfDay(_workingHours.endTime),
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Break Time
          Text('Break Time', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _workingHours.hasBreak,
            onChanged: (value) {
              setState(() {
                _workingHours = _workingHours.copyWith(hasBreak: value);
              });
            },
            title: Text(
              'Take Break',
              style: AppTextStyles.bodyMedium,
            ),
            activeColor: AppColors.accent,
          ),
          if (_workingHours.hasBreak) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Break Start',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _workingHours.breakStartTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _workingHours = _workingHours.copyWith(
                                breakStartTime: picked,
                              );
                            });
                          }
                        },
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
                            _formatTimeOfDay(_workingHours.breakStartTime),
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
                        'Break End',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _workingHours.breakEndTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _workingHours = _workingHours.copyWith(
                                breakEndTime: picked,
                              );
                            });
                          }
                        },
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
                            _formatTimeOfDay(_workingHours.breakEndTime),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 32),

          CustomButton(
            onPressed: _isLoading ? null : _saveWorkingHours,
            text: _isLoading ? 'Saving...' : 'Save Changes',
          ),
        ],
      ),
    );
  }

  Widget _buildDayToggle(String day, int index) {
    return SwitchListTile(
      value: _workingHours.workingDays[index],
      onChanged: (value) {
        setState(() {
          final newDays = List<bool>.from(_workingHours.workingDays);
          newDays[index] = value;
          _workingHours = _workingHours.copyWith(workingDays: newDays);
        });
      },
      title: Text(
        day,
        style: AppTextStyles.bodyMedium,
      ),
      activeColor: AppColors.accent,
    );
  }
}
