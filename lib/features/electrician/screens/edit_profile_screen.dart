import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../models/electrician_model.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  bool _isLoading = false;
  bool _isInitialized = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _rateController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _rateController = TextEditingController();
    _loadElectricianData();
  }

  Future<void> _loadElectricianData() async {
    try {
      setState(() => _isLoading = true);
      final dbProvider = context.read<DatabaseProvider>();

      // Load electrician data if not already loaded
      if (dbProvider.electricians.isEmpty) {
        await dbProvider.loadElectricians();
      }

      final electrician = dbProvider.electricians.first;

      // Update controllers with electrician data
      setState(() {
        _nameController.text = electrician.profile.name;
        _emailController.text = electrician.profile.email;
        _rateController.text = electrician.hourlyRate.toString();
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dbProvider = context.read<DatabaseProvider>();
      final currentElectrician = dbProvider.electricians.first;

      // Upload image if selected
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await dbProvider.uploadProfileImage(_imageFile!);
      }

      // Update electrician profile
      final updatedElectrician = currentElectrician.copyWith(
        profile: currentElectrician.profile.copyWith(
          name: _nameController.text,
          email: _emailController.text,
        ),
        hourlyRate: double.parse(_rateController.text),
        profileImage: imageUrl ?? currentElectrician.profileImage,
      );

      await dbProvider.updateElectricianProfile(updatedElectrician);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized && !_isLoading) {
      return const Scaffold(
        body: Center(
          child: Text('Failed to load profile data'),
        ),
      );
    }

    if (_isLoading && !_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Edit Profile', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                        image: _imageFile != null
                            ? DecorationImage(
                                image: FileImage(_imageFile!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: AppColors.surface,
                      ),
                      child: _imageFile == null
                          ? const Icon(Icons.person,
                              size: 60, color: AppColors.accent)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: AppColors.surface),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Personal Information
              Text('Personal Information', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Email is required' : null,
              ),
              const SizedBox(height: 32),

              // Rate Information
              Text('Rate Information', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _rateController,
                label: 'Hourly Rate (\$)',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Hourly rate is required' : null,
              ),
              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                onPressed: _isLoading ? null : _saveProfile,
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
