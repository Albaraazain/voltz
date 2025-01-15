import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/electrician_provider.dart';
import '../../../models/schedule_slot_model.dart';

class AvailabilityCalendarScreen extends StatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    try {
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      await context.read<ScheduleProvider>().loadScheduleSlots(
            electricianId: electricianId,
            date: _selectedDate,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load schedule'),
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

  Future<void> _createAvailabilitySlot() async {
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (timeOfDay != null && mounted) {
      final endTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(
          hour: timeOfDay.hour + 1,
          minute: timeOfDay.minute,
        ),
      );

      if (endTime != null && mounted) {
        try {
          setState(() => _isLoading = true);

          final electricianId =
              context.read<ElectricianProvider>().getCurrentElectricianId();
          await context.read<ScheduleProvider>().createScheduleSlot(
                electricianId: electricianId,
                date: _selectedDate,
                startTime:
                    '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}',
                endTime:
                    '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                status: ScheduleSlot.STATUS_AVAILABLE,
              );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Availability slot created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to create availability slot'),
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
    }
  }

  Widget _buildTimeSlot(ScheduleSlot slot) {
    final isAvailable = slot.status == ScheduleSlot.STATUS_AVAILABLE;
    final isBooked = slot.status == ScheduleSlot.STATUS_BOOKED;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isAvailable
                            ? Colors.green
                            : isBooked
                                ? Colors.orange
                                : Colors.red)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isBooked ? Icons.event_busy : Icons.access_time,
                    color: isAvailable
                        ? Colors.green
                        : isBooked
                            ? Colors.orange
                            : Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${slot.startTime} - ${slot.endTime}',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAvailable
                            ? 'Available'
                            : isBooked
                                ? 'Booked'
                                : 'Unavailable',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isAvailable
                              ? Colors.green
                              : isBooked
                                  ? Colors.orange
                                  : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isBooked)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Booked',
                      style: AppTextStyles.buttonMedium.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            if (isBooked && slot.job != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Details',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      slot.job!.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final slots = scheduleProvider.scheduleSlots;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Availability Calendar',
          style: AppTextStyles.h2,
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date',
                  style: AppTextStyles.h3.copyWith(color: AppColors.accent),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 90)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                      _loadSchedule();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.accent,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _selectedDate.toString().split(' ')[0],
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.accent,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : slots.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No schedule slots found',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add availability slots by tapping the + button',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: slots.length,
                        itemBuilder: (context, index) =>
                            _buildTimeSlot(slots[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAvailabilitySlot,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: AppColors.surface),
      ),
    );
  }
}
