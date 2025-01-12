import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_text_field.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late TextEditingController _accountNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _routingNumberController;
  late TextEditingController _bankNameController;
  String _selectedAccountType = 'Checking';

  @override
  void initState() {
    super.initState();
    _accountNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _routingNumberController = TextEditingController();
    _bankNameController = TextEditingController();
    _loadPaymentInfo();
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _loadPaymentInfo() {
    // TODO: Load payment info from database
  }

  Future<void> _savePaymentInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Save payment info to database
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update payment information')),
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
        title: Text('Payment Settings', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank Account Information
              Text('Bank Account Information', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _accountNameController,
                        label: 'Account Holder Name',
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _accountNumberController,
                        label: 'Account Number',
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Account number is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _routingNumberController,
                        label: 'Routing Number',
                        keyboardType: TextInputType.number,
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Routing number is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _bankNameController,
                        label: 'Bank Name',
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Bank name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Account Type', style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedAccountType,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        items: ['Checking', 'Savings']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedAccountType = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Payment History
              Text('Payment History', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              Card(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        'Payment #${1000 + index}',
                        style: AppTextStyles.bodyLarge,
                      ),
                      subtitle: Text(
                        'March ${15 - index}, 2024',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      trailing: Text(
                        '\$${(150 * (index + 1)).toStringAsFixed(2)}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                onPressed: _isLoading ? null : _savePaymentInfo,
                text: _isLoading ? 'Saving...' : 'Save Changes',
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
