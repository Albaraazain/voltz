import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/availability_slot_model.dart';
import '../../../providers/availability_provider.dart';
import '../../../providers/schedule_provider.dart';
import '../../common/widgets/loading_indicator.dart';
import '../screens/book_appointment_screen.dart';

class AvailabilityViewer extends StatefulWidget {
  final String electricianId;

  const AvailabilityViewer({
    super.key,
    required this.electricianId,
  });

  @override
  State<AvailabilityViewer> createState() => _AvailabilityViewerState();
}

class _AvailabilityViewerState extends State<AvailabilityViewer> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final availabilityProvider = context.read<AvailabilityProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();

    // Load availability for the next 30 days
    final endDate = DateTime.now().add(const Duration(days: 30));
    await availabilityProvider.loadAvailabilitySlots(
      widget.electricianId,
      DateTime.now(),
      endDate,
    );
    await scheduleProvider.loadScheduleSlots(
      widget.electricianId,
      DateTime.now(),
      endDate,
    );
  }

  Widget _buildTimeSlot(String time, bool isAvailable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 16,
            color: isAvailable ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  isAvailable ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          if (isAvailable)
            Text(
              'Available',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Text(
              'Booked',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  void _handleSlotSelection(AvailabilitySlot slot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookAppointmentScreen(
          electricianId: widget.electricianId,
          selectedSlot: slot,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 30)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: CalendarStyle(
            selectedDecoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: HeaderStyle(
            titleTextStyle: AppTextStyles.h3,
            formatButtonTextStyle: AppTextStyles.bodySmall,
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const Divider(height: 32),

        // Time Slots
        Expanded(
          child: Consumer2<AvailabilityProvider, ScheduleProvider>(
            builder: (context, availabilityProvider, scheduleProvider, child) {
              if (availabilityProvider.isLoading ||
                  scheduleProvider.isLoading) {
                return const LoadingIndicator();
              }

              final availableSlots = availabilityProvider.getAvailableSlots(
                _selectedDay,
                widget.electricianId,
              );

              final bookedSlots = scheduleProvider.getBookedSlots(
                _selectedDay,
                widget.electricianId,
              );

              if (availableSlots.isEmpty && bookedSlots.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'No availability',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try selecting a different date',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Combine and sort all slots
              final allSlots = <MapEntry<String, bool>>[
                for (final slot in availableSlots)
                  MapEntry(slot.startTime, true),
                for (final slot in bookedSlots) MapEntry(slot.startTime, false),
              ]..sort((a, b) => a.key.compareTo(b.key));

              return ListView.builder(
                itemCount: allSlots.length,
                itemBuilder: (context, index) {
                  final slot = allSlots[index];
                  final isAvailable = slot.value;
                  final time = slot.key;
                  final availabilitySlot = isAvailable
                      ? availableSlots.firstWhere((s) => s.startTime == time)
                      : null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: isAvailable
                          ? AppColors.surface
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: isAvailable
                            ? () => _handleSlotSelection(availabilitySlot!)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isAvailable
                                  ? AppColors.border
                                  : AppColors.textSecondary.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                time,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isAvailable
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                isAvailable ? 'Available' : 'Booked',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isAvailable
                                      ? AppColors.accent
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}