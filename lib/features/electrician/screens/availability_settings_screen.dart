import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../models/electrician_model.dart';
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
  bool _isAvailable = true;
  final Map<String, WorkingHours> _workingHours = {
    'Monday': WorkingHours(),
    'Tuesday': WorkingHours(),
    'Wednesday': WorkingHours(),
    'Thursday': WorkingHours(),
    'Friday': WorkingHours(),
    'Saturday': WorkingHours(),
    'Sunday': WorkingHours(),
  };

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  void _loadAvailability() {
    final electrician = context.read<DatabaseProvider>().electricians.first;
    setState(() {
      _isAvailable = electrician.isAvailable;
      // TODO: Load working hours from electrician model
    });
  }

  Future<void> _saveAvailability() async {
    setState(() => _isLoading = true);

    try {
      final dbProvider = context.read<DatabaseProvider>();
      await dbProvider.updateElectricianAvailability(
        dbProvider.electricians.first.id,
        _isAvailable,
      );
      // TODO: Save working hours
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update availability')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Availability Settings', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Availability Toggle
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available for Work', style: AppTextStyles.h3),
                          Text(
                            'Toggle this to show/hide your profile from search results',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() => _isAvailable = value);
                      },
                      activeColor: AppColors.accent,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Working Hours
            Text('Working Hours', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            ..._workingHours.entries.map((entry) {
              return _buildDaySchedule(entry.key, entry.value);
            }),

            const SizedBox(height: 32),
            CustomButton(
              onPressed: _isLoading ? null : _saveAvailability,
              text: _isLoading ? 'Saving...' : 'Save Changes',
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day, WorkingHours hours) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(day, style: AppTextStyles.bodyLarge),
                ),
                Switch(
                  value: hours.isWorking,
                  onChanged: (value) {
                    setState(() => hours.isWorking = value);
                  },
                  activeColor: AppColors.accent,
                ),
              ],
            ),
            if (hours.isWorking) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Time',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context, hours, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatTimeOfDay(hours.startTime),
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
                        Text('End Time',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context, hours, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatTimeOfDay(hours.endTime),
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
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
      BuildContext context, WorkingHours hours, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? hours.startTime : hours.endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          hours.startTime = picked;
        } else {
          hours.endTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class WorkingHours {
  bool isWorking;
  TimeOfDay startTime;
  TimeOfDay endTime;

  WorkingHours({
    this.isWorking = true,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  })  : startTime = startTime ?? const TimeOfDay(hour: 9, minute: 0),
        endTime = endTime ?? const TimeOfDay(hour: 17, minute: 0);
}
