import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/electrician_provider.dart';
import '../../../models/schedule_slot_model.dart';
import '../../common/widgets/custom_button.dart';

class ScheduleOverviewScreen extends StatefulWidget {
  const ScheduleOverviewScreen({super.key});

  @override
  State<ScheduleOverviewScreen> createState() => _ScheduleOverviewScreenState();
}

class _ScheduleOverviewScreenState extends State<ScheduleOverviewScreen> {
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
          const SnackBar(content: Text('Failed to load schedule')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTimeSlot(ScheduleSlot slot) {
    final isAvailable = slot.status == ScheduleSlot.STATUS_AVAILABLE;
    final isBooked = slot.status == ScheduleSlot.STATUS_BOOKED;

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
                  '${slot.startTime} - ${slot.endTime}',
                  style: AppTextStyles.h3,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green
                        : isBooked
                            ? Colors.orange
                            : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    slot.status,
                    style:
                        AppTextStyles.bodySmall.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            if (isBooked && slot.job != null) ...[
              const SizedBox(height: 16),
              Text(
                'Job Details:',
                style: AppTextStyles.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                slot.job!.description,
                style: AppTextStyles.bodyMedium,
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
        title: Text(
          'Schedule Overview',
          style: AppTextStyles.h2,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Selected Date: ${_selectedDate.toString().split(' ')[0]}',
                    style: AppTextStyles.bodyLarge,
                  ),
                ),
                CustomButton(
                  onPressed: () async {
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
                  text: 'Change Date',
                  type: ButtonType.secondary,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : slots.isEmpty
                    ? Center(
                        child: Text(
                          'No schedule slots found',
                          style: AppTextStyles.bodyLarge,
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
    );
  }
}
