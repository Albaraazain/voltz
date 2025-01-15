import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/working_hours_model.dart';
import '../../../models/schedule_slot_model.dart';
import '../../../providers/electrician_provider.dart';
import '../../../providers/schedule_provider.dart';
import '../../common/widgets/custom_button.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  List<WorkingHours>? _workingHours;
  final List<String> _weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  final List<String> _quickTimeSlots = [
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
    _loadSchedule();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);

    try {
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      LoggerService.info('Loading schedule for electrician: $electricianId');
      LoggerService.info('Selected date: ${_selectedDate.toString()}');

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

  Future<void> _loadWorkingHours() async {
    try {
      final electricianId =
          context.read<ElectricianProvider>().getCurrentElectricianId();
      LoggerService.info(
          'Loading working hours for electrician: $electricianId');
      final workingHours = await context
          .read<ScheduleProvider>()
          .loadWorkingHours(electricianId);
      LoggerService.info('Loaded working hours: $workingHours');
      setState(() {
        _workingHours = List<WorkingHours>.from(workingHours);
      });
    } catch (e) {
      LoggerService.error('Failed to load working hours', e);
    }
  }

  bool _isDateAvailable(DateTime date) {
    if (_workingHours == null) {
      LoggerService.info('Working hours is null, defaulting to available');
      return true;
    }

    final dayOfWeek = date.weekday % 7; // Convert to 0-6 (Sun-Sat)
    final daySchedule = _workingHours!.firstWhere(
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

    LoggerService.info(
        'Checking availability for day $dayOfWeek: $daySchedule');
    return daySchedule.isWorkingDay;
  }

  String _getTimeRange(int dayOfWeek) {
    if (_workingHours == null) return '';

    final daySchedule = _workingHours!.firstWhere(
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

    if (!daySchedule.isWorkingDay) {
      return 'Unavailable';
    }
    return '${daySchedule.startTime} - ${daySchedule.endTime}';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child:
                    Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
                child:
                    Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _createAvailabilitySlot([String? quickSlot]) async {
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    try {
      LoggerService.info('Starting availability slot creation process');

      if (quickSlot != null) {
        final times = quickSlot.split(' - ');
        final startParts = times[0].split(':');
        final endParts = times[1].split(':');
        startTime = TimeOfDay(
          hour: int.parse(startParts[0]),
          minute: int.parse(startParts[1]),
        );
        endTime = TimeOfDay(
          hour: int.parse(endParts[0]),
          minute: int.parse(endParts[1]),
        );
      } else {
        startTime = await _showCustomTimePicker(initialTime: TimeOfDay.now());
        if (startTime != null && mounted) {
          endTime = await _showCustomTimePicker(
            initialTime:
                TimeOfDay(hour: startTime.hour + 1, minute: startTime.minute),
          );
        }
      }

      if (startTime != null && endTime != null && mounted) {
        setState(() => _isLoading = true);
        final electricianId =
            context.read<ElectricianProvider>().getCurrentElectricianId();

        final formattedStartTime =
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
        final formattedEndTime =
            '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

        await context.read<ScheduleProvider>().createScheduleSlot(
              electricianId: electricianId,
              date: _selectedDate,
              startTime: formattedStartTime,
              endTime: formattedEndTime,
              status: ScheduleSlot.STATUS_AVAILABLE,
            );

        if (mounted) {
          _showSuccessSnackBar('Availability slot created successfully');
        }
      }
    } catch (e) {
      LoggerService.error('Failed to create availability slot', e);
      if (mounted) {
        _showErrorSnackBar('Failed to create slot: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<TimeOfDay?> _showCustomTimePicker({required TimeOfDay initialTime}) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? AppColors.primary
                      : AppColors.surface),
              hourMinuteColor: WidgetStateColor.resolveWith((states) =>
                  states.contains(WidgetState.selected)
                      ? AppColors.primary
                      : AppColors.surface),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final scheduleSlots = scheduleProvider.scheduleSlots;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: true,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Schedule',
                style: AppTextStyles.h2.copyWith(color: Colors.white),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSelector(),
                  const SizedBox(height: 24),
                  _buildQuickSlots(),
                  const SizedBox(height: 24),
                  _buildScheduleList(scheduleSlots),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createAvailabilitySlot(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Custom Slot', style: TextStyle(color: Colors.white)),
      )
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 500))
          .slideX(begin: 1, end: 0),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 100,
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // Show next 2 weeks
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final isAvailable = _isDateAvailable(date);
          final dayName = DateFormat('EEEE').format(date);
          final timeRange = _getTimeRange(date.weekday % 7);

          return Tooltip(
            message: timeRange,
            child: GestureDetector(
              onTap: isAvailable
                  ? () {
                      setState(() => _selectedDate = date);
                      _loadSchedule();
                    }
                  : null,
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isAvailable
                          ? Colors.transparent
                          : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: isAvailable && !isSelected
                      ? Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekDays[date.weekday - 1],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isAvailable
                                ? AppColors.textSecondary
                                : AppColors.textSecondary.withOpacity(0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isAvailable
                                ? AppColors.textPrimary
                                : AppColors.textPrimary.withOpacity(0.5),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isAvailable)
                      Icon(
                        Icons.block,
                        size: 12,
                        color: Colors.red.withOpacity(0.5),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Slots', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickTimeSlots.map((slot) {
            return InkWell(
              onTap: () => _createAvailabilitySlot(slot),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(
                    delay: Duration(
                        milliseconds: _quickTimeSlots.indexOf(slot) * 100))
                .slideY(begin: 0.2, end: 0);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScheduleList(List<ScheduleSlot> slots) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (slots.isEmpty) {
      final isDateAvailable = _isDateAvailable(_selectedDate);
      final dayName = DateFormat('EEEE').format(_selectedDate);
      final timeRange = _getTimeRange(_selectedDate.weekday % 7);

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDateAvailable ? Icons.event_available : Icons.event_busy,
              size: 64,
              color: isDateAvailable
                  ? AppColors.primary.withOpacity(0.5)
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isDateAvailable
                  ? 'No slots created for this date\nWorking hours: $timeRange'
                  : 'Not available on this day',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            if (isDateAvailable) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _createAvailabilitySlot,
                icon: const Icon(Icons.add),
                label: const Text('Create Availability'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn().scale();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Schedule', style: AppTextStyles.h3),
            Text(
              DateFormat('EEEE, MMMM d').format(_selectedDate),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...slots.map((slot) {
          final startTime = TimeOfDay(
            hour: int.parse(slot.startTime.split(':')[0]),
            minute: int.parse(slot.startTime.split(':')[1]),
          );
          final endTime = TimeOfDay(
            hour: int.parse(slot.endTime.split(':')[0]),
            minute: int.parse(slot.endTime.split(':')[1]),
          );

          final isAvailable = slot.status == ScheduleSlot.STATUS_AVAILABLE;
          final isBooked = slot.status == ScheduleSlot.STATUS_BOOKED;

          return Dismissible(
            key: Key(slot.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              if (!isAvailable) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        'Cannot delete a booked or unavailable slot'),
                    backgroundColor: Colors.red.shade800,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                return false;
              }
              return true;
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
            ),
            onDismissed: (direction) async {
              try {
                await context
                    .read<ScheduleProvider>()
                    .deleteScheduleSlot(slot.id);
                _showSuccessSnackBar('Slot deleted successfully');
              } catch (e) {
                _showErrorSnackBar('Failed to delete slot: ${e.toString()}');
              }
            },
            child: GestureDetector(
              onTap: isAvailable
                  ? () async {
                      LoggerService.info(
                          'Attempting to navigate to book appointment screen');

                      final electricianId = context
                          .read<ElectricianProvider>()
                          .getCurrentElectricianId();
                      LoggerService.debug('Electrician ID: $electricianId');

                      LoggerService.debug('Slot details before navigation:\n'
                          'ID: ${slot.id}\n'
                          'Date: ${slot.date}\n'
                          'Time: ${slot.startTime} - ${slot.endTime}\n'
                          'Status: ${slot.status}');

                      final slotJson = slot.toJson();
                      LoggerService.debug('Slot JSON: $slotJson');

                      try {
                        final result = await Navigator.pushNamed(
                          context,
                          '/book_appointment',
                          arguments: {
                            'electricianId': electricianId,
                            'slot': slot.toJson(),
                          },
                        );
                        LoggerService.debug('Navigation result: $result');

                        if (result == true) {
                          LoggerService.info(
                              'Appointment booked successfully, reloading schedule');
                          _loadSchedule();
                        }
                      } catch (e, stackTrace) {
                        LoggerService.error(
                          'Failed to navigate to book appointment screen',
                          e,
                          stackTrace,
                        );
                        _showErrorSnackBar(
                            'Failed to open booking screen: ${e.toString()}');
                      }
                    }
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.3)
                        : isBooked
                            ? Colors.orange.withOpacity(0.3)
                            : Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
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
                        isBooked
                            ? Icons.event_busy
                            : isAvailable
                                ? Icons.event_available
                                : Icons.block,
                        color: isAvailable
                            ? Colors.green
                            : isBooked
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${startTime.format(context)} - ${endTime.format(context)}',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAvailable
                                ? 'Available for Booking'
                                : isBooked
                                    ? 'Appointment Booked'
                                    : 'Slot Unavailable',
                            style: TextStyle(
                              color: isAvailable
                                  ? Colors.green
                                  : isBooked
                                      ? Colors.orange
                                      : Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          if (isBooked && slot.job != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.work_outline,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      slot.job!.description,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: slots.indexOf(slot) * 100))
              .slideX();
        }).toList(),
      ],
    );
  }
}
