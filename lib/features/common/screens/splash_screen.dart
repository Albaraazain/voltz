import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/services/logger_service.dart';
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

  Future<void> _debugDatabaseTables() async {
    try {
      final dbProvider = context.read<DatabaseProvider>();

      // List of tables we want to debug
      final tables = ['profiles', 'homeowners', 'electricians', 'jobs'];

      LoggerService.info('Available tables in public schema:');
      for (final tableName in tables) {
        LoggerService.info('Table: $tableName');

        try {
          // Get 2 rows from each table
          final rowsResponse =
              await dbProvider.client.from(tableName).select().limit(2);

          LoggerService.info('Sample rows:');
          for (final row in rowsResponse) {
            LoggerService.info(row.toString());
          }
        } catch (e) {
          LoggerService.info('No rows found or no access');
        }
        LoggerService.info('-------------------');
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error debugging database tables', e, stackTrace);
    }
  }

  Future<void> _initializeAndNavigate() async {
    try {
      // Debug database tables
      await _debugDatabaseTables();

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
