import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/electrician_provider.dart';
import '../../../models/direct_request_model.dart';
import '../../common/widgets/custom_button.dart';

class ScheduleOverviewScreen extends StatefulWidget {
  const ScheduleOverviewScreen({super.key});

  @override
  State<ScheduleOverviewScreen> createState() => _ScheduleOverviewScreenState();
}

class _ScheduleOverviewScreenState extends State<ScheduleOverviewScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
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
      final startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      await context.read<ScheduleProvider>().loadScheduleSlots(
            electricianId,
            startDate,
            endDate,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load schedule')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildScheduleTimeline() {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final selectedDate = _selectedDay.toIso8601String().split('T')[0];
    final scheduleSlots = scheduleProvider.scheduleSlots[selectedDate] ?? [];

    if (scheduleSlots.isEmpty) {
      return Center(
        child: Text(
          'No appointments scheduled for this day',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: scheduleSlots.length,
      itemBuilder: (context, index) {
        final slot = scheduleSlots[index];
        final isBooked = slot.status == ScheduleSlot.STATUS_BOOKED;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${slot.startTime} - ${slot.endTime}',
                      style: AppTextStyles.h3,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isBooked ? AppColors.accent : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        slot.status,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (isBooked) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Client Name', // TODO: Add client name from job details
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.work_outline,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Job Type', // TODO: Add job type from job details
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                        onPressed: () {
                          // TODO: Navigate to job details screen
                        },
                        text: 'View Details',
                        type: ButtonType.secondary,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
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
          'Schedule Overview',
          style: AppTextStyles.h2,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month
                    ? CalendarFormat.week
                    : CalendarFormat.month;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.surface,
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2025, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent),
                ),
                markersAlignment: Alignment.bottomCenter,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTextStyles.h3,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadSchedule();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildScheduleTimeline(),
          ),
        ],
      ),
    );
  }
}
