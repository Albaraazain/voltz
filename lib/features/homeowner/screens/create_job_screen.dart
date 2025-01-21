import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/service_model.dart';
import '../../../models/service_category_model.dart';
import 'package:intl/intl.dart';
import '../../../features/homeowner/screens/find_professional_map_screen.dart';

class CreateJobScreen extends StatefulWidget {
  final Service service;
  final ServiceCategory category;

  const CreateJobScreen({
    super.key,
    required this.service,
    required this.category,
  });

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _hours = 2; // Default to minimum hours
  String _additionalNotes = '';
  double _maxBudgetPerHour = 0;
  int _currentStep = 0;

  double get _totalPrice => widget.service.price * _hours;

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _hours = widget.category.minimumHours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Book ${widget.service.title}',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() {
                _currentStep++;
              });
            } else {
              _submitJob();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            }
          },
          steps: [
            // Step 1: Schedule
            Step(
              title: const Text('Schedule'),
              content: Column(
                children: [
                  // Date Selection
                  ListTile(
                    title: Text(
                      'Select Date',
                      style: AppTextStyles.bodyLarge,
                    ),
                    subtitle: Text(
                      _selectedDate == null
                          ? 'Tap to select date'
                          : DateFormat('EEEE, MMMM d, y')
                              .format(_selectedDate!),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: _selectDate,
                  ),
                  const SizedBox(height: 16),
                  // Time Selection
                  ListTile(
                    title: Text(
                      'Select Time',
                      style: AppTextStyles.bodyLarge,
                    ),
                    subtitle: Text(
                      _selectedTime == null
                          ? 'Tap to select time'
                          : _selectedTime!.format(context),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: _selectTime,
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0
                  ? StepState.complete
                  : _selectedDate != null && _selectedTime != null
                      ? StepState.complete
                      : StepState.indexed,
            ),

            // Step 2: Service Details
            Step(
              title: const Text('Service Details'),
              content: Column(
                children: [
                  // Hours Selection
                  ListTile(
                    title: Text(
                      'Number of Hours',
                      style: AppTextStyles.bodyLarge,
                    ),
                    subtitle: Text(
                      'Minimum ${widget.category.minimumHours} hours required',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _hours > widget.category.minimumHours
                              ? () => setState(() => _hours--)
                              : null,
                        ),
                        Text(
                          '$_hours hrs',
                          style: AppTextStyles.bodyLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _hours < 8
                              ? () => setState(() => _hours++)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Budget per Hour
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Maximum Budget per Hour',
                      hintText:
                          'Enter maximum amount you\'re willing to pay per hour',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your maximum budget per hour';
                      }
                      final budget = double.tryParse(value);
                      if (budget == null || budget <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      final budget = double.tryParse(value);
                      if (budget != null) {
                        setState(() => _maxBudgetPerHour = budget);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Additional Notes
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes (Optional)',
                      hintText: 'Any special requirements or instructions...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) => _additionalNotes = value,
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),

            // Step 3: Review & Confirm
            Step(
              title: const Text('Review & Confirm'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReviewItem(
                    'Service',
                    widget.service.title,
                    Icons.home_repair_service,
                  ),
                  _buildReviewItem(
                    'Date & Time',
                    _selectedDate == null
                        ? 'Not selected'
                        : '${DateFormat('EEEE, MMMM d, y').format(_selectedDate!)} at ${_selectedTime?.format(context)}',
                    Icons.event,
                  ),
                  _buildReviewItem(
                    'Duration',
                    '$_hours hours',
                    Icons.timer,
                  ),
                  _buildReviewItem(
                    'Total Price',
                    '\$${_totalPrice.toStringAsFixed(2)}',
                    Icons.attach_money,
                    highlight: true,
                  ),
                  if (_additionalNotes.isNotEmpty)
                    _buildReviewItem(
                      'Additional Notes',
                      _additionalNotes,
                      Icons.note,
                    ),
                ],
              ),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(
    String title,
    String value,
    IconData icon, {
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (highlight ? AppColors.primary : AppColors.textSecondary)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: highlight ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: highlight ? AppColors.primary : null,
                    fontWeight: highlight ? FontWeight.w600 : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitJob() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_maxBudgetPerHour <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your maximum budget per hour'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FindProfessionalMapScreen(
          service: widget.service,
          hours: _hours,
          maxBudgetPerHour: _maxBudgetPerHour,
          scheduledDate: _selectedDate!,
          scheduledTime: _selectedTime!,
          additionalNotes:
              _additionalNotes.isNotEmpty ? _additionalNotes : null,
        ),
      ),
    );
  }
}
