import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../models/payment_info_model.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_text_field.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _routingNumberController = TextEditingController();
  bool _isLoading = false;
  String _selectedAccountType = 'Checking';

  @override
  void initState() {
    super.initState();
    _loadPaymentInfo();
  }

  void _loadPaymentInfo() {
    final electrician =
        context.read<DatabaseProvider>().electricians.firstWhere(
              (e) =>
                  e.profile.id ==
                  context.read<DatabaseProvider>().currentProfile?.id,
            );

    if (electrician.paymentInfo != null) {
      setState(() {
        _accountNameController.text =
            electrician.paymentInfo!.accountName ?? '';
        _accountNumberController.text =
            electrician.paymentInfo!.accountNumber ?? '';
        _bankNameController.text = electrician.paymentInfo!.bankName ?? '';
        _routingNumberController.text =
            electrician.paymentInfo!.routingNumber ?? '';
        _selectedAccountType =
            electrician.paymentInfo!.accountType ?? 'Checking';
      });
    }
  }

  Future<void> _savePaymentInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final paymentInfo = PaymentInfo(
        accountName: _accountNameController.text,
        accountNumber: _accountNumberController.text,
        bankName: _bankNameController.text,
        routingNumber: _routingNumberController.text,
        accountType: _selectedAccountType,
      );

      try {
        final dbProvider = context.read<DatabaseProvider>();
        final currentElectrician = dbProvider.electricians.firstWhere(
          (e) => e.profile.id == dbProvider.currentProfile?.id,
        );

        final updatedElectrician = currentElectrician.copyWith(
          paymentInfo: paymentInfo,
        );

        await dbProvider.updateElectricianProfile(updatedElectrician);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Payment information saved successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving payment information: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Payment Settings',
          style: AppTextStyles.h2,
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bank Account Information', style: AppTextStyles.h3),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _accountNameController,
                label: 'Account Holder Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _accountNumberController,
                label: 'Account Number',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter account number';
                  }
                  if (value.length < 8) {
                    return 'Account number must be at least 8 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bankNameController,
                label: 'Bank Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter bank name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _routingNumberController,
                label: 'Routing Number',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter routing number';
                  }
                  if (value.length != 9) {
                    return 'Routing number must be 9 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Account Type',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedAccountType,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none,
                  ),
                  items: ['Checking', 'Savings'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: AppTextStyles.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedAccountType = value);
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: _isLoading ? null : _savePaymentInfo,
                text: _isLoading ? 'Saving...' : 'Save Changes',
              ),
              const SizedBox(height: 24),
              Text(
                'Note: Your payment information is securely stored and encrypted.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
