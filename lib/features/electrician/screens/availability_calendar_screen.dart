import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/availability_provider.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/electrician_provider.dart';
import '../../common/widgets/custom_button.dart';
import '../../../models/availability_slot_model.dart';

class AvailabilityCalendarScreen extends StatefulWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      final startDate = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endDate = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      // Load both availability and schedule data
      await Future.wait([
        context.read<AvailabilityProvider>().loadAvailabilitySlots(
              electricianId,
              startDate,
              endDate,
            ),
        context.read<ScheduleProvider>().loadScheduleSlots(
              electricianId,
              startDate,
              endDate,
            ),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load calendar data')),
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
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (timeOfDay != null && mounted) {
      try {
        final electricianId =
            context.read<ElectricianProvider>().getCurrentElectricianId();
        final startTime =
            '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';

        await context.read<AvailabilityProvider>().createAvailabilitySlot(
              AvailabilitySlot(
                id: '',
                electricianId: electricianId,
                date: _selectedDay.toIso8601String().split('T')[0],
                startTime: startTime,
                endTime:
                    '${(timeOfDay.hour + 1).toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}',
                status: AvailabilitySlot.STATUS_AVAILABLE,
              ),
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Availability slot created')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create availability slot')),
          );
        }
      }
    }
  }

  Widget _buildTimeSlots() {
    final availabilityProvider = context.watch<AvailabilityProvider>();
    final scheduleProvider = context.watch<ScheduleProvider>();
    final selectedDate = _selectedDay.toIso8601String().split('T')[0];

    final availabilitySlots =
        availabilityProvider.availabilitySlots[selectedDate] ?? [];
    final scheduleSlots = scheduleProvider.scheduleSlots[selectedDate] ?? [];

    if (availabilitySlots.isEmpty && scheduleSlots.isEmpty) {
      return Center(
        child: Text(
          'No availability or bookings for this day',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (availabilitySlots.isNotEmpty) ...[
          Text('Available Slots', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          ...availabilitySlots.map((slot) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${slot.startTime} - ${slot.endTime}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        await context
                            .read<AvailabilityProvider>()
                            .deleteAvailabilitySlot(slot.id, selectedDate);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Slot deleted')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to delete slot')),
                          );
                        }
                      }
                    },
                  ),
                ),
              )),
        ],
        if (scheduleSlots.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Bookings', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          ...scheduleSlots.map((slot) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text('${slot.startTime} - ${slot.endTime}'),
                  subtitle: Text(slot.status),
                  leading: Icon(
                    slot.status == ScheduleSlot.STATUS_BOOKED
                        ? Icons.event_busy
                        : Icons.event_available,
                    color: slot.status == ScheduleSlot.STATUS_BOOKED
                        ? AppColors.accent
                        : AppColors.primary,
                  ),
                ),
              )),
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
          'Availability Calendar',
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
                _loadData();
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTimeSlots(),
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
