import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../common/widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserType _selectedUserType = UserType.homeowner;
  bool _isLoading = false;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome Back', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(
              'Login to your account',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            // User Type Selection
            Row(
              children: [
                Expanded(
                  child: _UserTypeButton(
                    title: 'Homeowner',
                    isSelected: _selectedUserType == UserType.homeowner,
                    onTap: () => setState(() {
                      _selectedUserType = UserType.homeowner;
                    }),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _UserTypeButton(
                    title: 'Electrician',
                    isSelected: _selectedUserType == UserType.electrician,
                    onTap: () => setState(() {
                      _selectedUserType = UserType.electrician;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              label: 'Password',
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.link,
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: _handleLogin,
              text: 'Login',
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().signIn(
            _emailController.text,
            _passwordController.text,
            _selectedUserType,
          );
      // TODO: Navigate to appropriate dashboard
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class _UserTypeButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: AppTextStyles.buttonMedium.copyWith(
            color: isSelected ? AppColors.accent : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
