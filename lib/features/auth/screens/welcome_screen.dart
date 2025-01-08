import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../../common/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Welcome Illustration
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Icon(
                    Icons.handyman_outlined,
                    size: 100,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Welcome Text
              Text(
                'Welcome to ElectriConnect',
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Connect with skilled electricians or find new clients for your electrical services',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Action Buttons
              CustomButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                text: 'Login',
                type: ButtonType.primary,
              ),
              const SizedBox(height: 16),
              CustomButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                text: 'Create Account',
                type: ButtonType.secondary,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
