import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/job_model.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../services/logger_service.dart';
import '../../../services/payment_service.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_text_field.dart';

class CreateJobScreen extends StatefulWidget {
  static const String routeName = '/create-job';

  // TODO: Add job type selection (Requires: Job categories system)
  // TODO: Add location picker (Requires: Location services)
  // TODO: Add photo/video upload (Requires: Media handling system)
  // TODO: Add smart pricing suggestions (Requires: Pricing engine)
  // TODO: Add scheduling preferences (Requires: Calendar system)
  // TODO: Add emergency flag option (Requires: Emergency system)
  // TODO: Add preferred electrician selection (Requires: Electrician matching system)
  // TODO: Add materials estimation (Requires: Inventory system)
  // TODO: Add job complexity assessment (Requires: Job assessment system)
  // TODO: Add preferred payment method (Requires: Payment system)

  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeownerProfile();
    });
  }

  Future<void> _loadHomeownerProfile() async {
    final databaseProvider = context.read<DatabaseProvider>();
    if (databaseProvider.currentHomeowner == null &&
        !databaseProvider.isLoading) {
      await databaseProvider.loadCurrentProfile();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }

    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }

    if (!Job.isValidPrice(price)) {
      return 'Price must be between \$${Job.MIN_PRICE} and \$${Job.MAX_PRICE}';
    }

    return null;
  }

  Future<void> _createJob() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Get the current homeowner
        final homeowner = Provider.of<DatabaseProvider>(context, listen: false)
            .currentHomeowner;
        if (homeowner == null) {
          throw Exception('Homeowner profile not found');
        }

        LoggerService.info('Creating job with homeowner ID: ${homeowner.id}');

        // Create a unique ID for the job
        final jobId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

        // Process payment first
        LoggerService.info(
            'Processing payment for job: $jobId, amount: \$${_priceController.text}');

        final paymentResult = await PaymentService.processPayment(
          amount: double.parse(_priceController.text),
          jobId: jobId,
        );

        if (paymentResult['status'] != Job.PAYMENT_STATUS_COMPLETED) {
          throw Exception(paymentResult['error'] ?? 'Payment failed');
        }

        // Create the job object
        final job = Job(
          id: jobId,
          title: _titleController.text,
          description: _descriptionController.text,
          status: Job.STATUS_PENDING,
          date: DateTime.now(),
          homeownerId: homeowner.id,
          price: double.parse(_priceController.text),
          createdAt: DateTime.now(),
          paymentStatus: paymentResult['status'],
          verificationStatus: Job.VERIFICATION_STATUS_PENDING,
          paymentDetails: paymentResult,
        );

        // Add the job to the database
        await Provider.of<JobProvider>(context, listen: false).addJob(job);

        setState(() {
          _isLoading = false;
        });

        // Show success message and navigate back
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job created successfully')),
        );
        Navigator.of(context).pop();
      } catch (e, stackTrace) {
        setState(() {
          _isLoading = false;
        });
        LoggerService.error(
          'Failed to create job',
          error: e,
          stackTrace: stackTrace,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create job: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Create New Job',
          style: AppTextStyles.h2,
        ),
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, databaseProvider, child) {
          if (databaseProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (databaseProvider.currentHomeowner == null) {
            return const Center(
              child:
                  Text('Failed to load homeowner profile. Please try again.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _titleController,
                    label: 'Job Title',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a job title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a job description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _priceController,
                    label: 'Budget (\$)',
                    keyboardType: TextInputType.number,
                    validator: _validatePrice,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preferred Date',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    onPressed: _isLoading ? null : _createJob,
                    text: 'Create Job',
                    type: ButtonType.primary,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
