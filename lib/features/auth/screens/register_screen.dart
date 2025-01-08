import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../common/widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserType _selectedUserType = UserType.homeowner;
  bool _isLoading = false;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 3,
                backgroundColor: AppColors.primary.withOpacity(0.3),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Create Account', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'Step ${_currentStep + 1} of 3',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Registration Steps
                    _buildCurrentStep(),
                    const SizedBox(height: 32),
                    // Navigation Buttons
                    Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: CustomButton(
                              onPressed: () {
                                setState(() {
                                  _currentStep--;
                                });
                              },
                              text: 'Back',
                              type: ButtonType.secondary,
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            onPressed: _handleNextStep,
                            text: _currentStep == 2 ? 'Create Account' : 'Next',
                            isLoading: _isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildUserTypeStep();
      case 1:
        return _buildBasicInfoStep();
      case 2:
        return _buildPasswordStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildUserTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'I am a...',
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: 24),
        _UserTypeCard(
          title: 'Homeowner',
          description: 'Find and hire qualified electricians for your home',
          icon: Icons.home_outlined,
          isSelected: _selectedUserType == UserType.homeowner,
          onTap: () => setState(() {
            _selectedUserType = UserType.homeowner;
          }),
        ),
        const SizedBox(height: 16),
        _UserTypeCard(
          title: 'Electrician',
          description: 'Offer your services and connect with clients',
          icon: Icons.electrical_services_outlined,
          isSelected: _selectedUserType == UserType.electrician,
          onTap: () => setState(() {
            _selectedUserType = UserType.electrician;
          }),
        ),
      ],
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _fullNameController,
          label: 'Full Name',
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _passwordController,
          label: 'Password',
          isPassword: true,
          prefixIcon: Icons.lock_outline,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a password';
            }
            if (value!.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          isPassword: true,
          prefixIcon: Icons.lock_outline,
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _handleNextStep() async {
    if (_currentStep < 2) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _isLoading = true);
        try {
          await context.read<AuthProvider>().signUp(
                _emailController.text,
                _passwordController.text,
                _selectedUserType,
                fullName: _fullNameController.text,
              );

          if (mounted) {
            // Navigate and remove all previous routes
            Navigator.of(context).pushNamedAndRemoveUntil(
              _selectedUserType == UserType.homeowner
                  ? '/homeowner/dashboard'
                  : '/electrician/dashboard',
              (route) => false,
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration failed: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    }
  }
}

class _UserTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent
                    : AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.surface : AppColors.accent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      color:
                          isSelected ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
