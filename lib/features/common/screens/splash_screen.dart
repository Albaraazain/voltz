import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/database_provider.dart';
import '../../auth/screens/welcome_screen.dart';
import '../../homeowner/screens/homeowner_main_screen.dart';
import '../../electrician/screens/electrician_main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Initialize database
      await context.read<DatabaseProvider>().initializeData();

      // Add a minimum delay to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();

      if (authProvider.isAuthenticated) {
        // Navigate to appropriate dashboard based on user type
        Navigator.of(context).pushReplacementNamed(
          authProvider.userType == UserType.homeowner
              ? '/homeowner/dashboard'
              : '/electrician/dashboard',
        );
      } else {
        // Navigate to welcome screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error initializing app: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );

      // Navigate to welcome screen on error
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.handyman_outlined,
              size: 100,
              color: AppColors.accent,
            ),
            const SizedBox(height: 24),
            Text(
              'ElectriConnect',
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
