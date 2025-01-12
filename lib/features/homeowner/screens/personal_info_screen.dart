import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/primary_button.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emergencyContactController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final homeowner = context.read<DatabaseProvider>().currentHomeowner;
    final profile = context.read<DatabaseProvider>().currentProfile;

    _nameController = TextEditingController(text: profile?.name);
    _phoneController = TextEditingController(text: homeowner?.phone);
    _emergencyContactController =
        TextEditingController(text: homeowner?.emergencyContact);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement save changes in DatabaseProvider
      // await context.read<DatabaseProvider>().updateProfile(
      //   name: _nameController.text,
      //   phone: _phoneController.text,
      //   emergencyContact: _emergencyContactController.text,
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving changes: $e')),
        );
      }
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
        elevation: 0,
        title: Text(
          'Personal Information',
          style: AppTextStyles.h2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Information',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  // Add phone number validation if needed
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Emergency Contact',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emergencyContactController,
                label: 'Emergency Contact Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an emergency contact';
                  }
                  // Add phone number validation if needed
                  return null;
                },
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                onPressed: _isLoading ? null : _saveChanges,
                isLoading: _isLoading,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
