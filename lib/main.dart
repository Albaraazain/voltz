import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/logger_service.dart';
import 'core/config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/electrician_provider.dart';
import 'providers/homeowner_provider.dart';
import 'providers/database_provider.dart';
import 'providers/job_provider.dart';
import 'features/common/screens/splash_screen.dart';
import 'features/homeowner/screens/homeowner_main_screen.dart';
import 'features/electrician/screens/electrician_main_screen.dart';
import 'features/homeowner/screens/create_job_screen.dart';
import 'features/electrician/screens/edit_profile_screen.dart';

Future<void> validateDatabaseSchema() async {
  final client = SupabaseConfig.client;
  LoggerService.info('Validating database schema...');

  try {
    // Check electricians table
    final electricians = await client.from('electricians').select().limit(1);
    LoggerService.info(
        'Electricians table schema: ${electricians.isEmpty ? "empty" : electricians.first.keys.join(", ")}');

    // Check homeowners table
    final homeowners = await client.from('homeowners').select().limit(1);
    LoggerService.info(
        'Homeowners table schema: ${homeowners.isEmpty ? "empty" : homeowners.first.keys.join(", ")}');

    // Check jobs table
    final jobs = await client.from('jobs').select().limit(1);
    LoggerService.info(
        'Jobs table schema: ${jobs.isEmpty ? "empty" : jobs.first.keys.join(", ")}');

    LoggerService.info('Database schema validation completed successfully');
  } catch (e, stackTrace) {
    LoggerService.error('Database schema validation failed', e, stackTrace);
    rethrow;
  }
}

void main() async {
  try {
    LoggerService.info('Application startup initiated');

    // Initialize Flutter bindings
    WidgetsFlutterBinding.ensureInitialized();
    LoggerService.info('Flutter bindings initialized');

    // Initialize Supabase
    LoggerService.info('Initializing Supabase connection...');
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    LoggerService.info('Supabase connection initialized successfully');

    // Validate database schema
    await validateDatabaseSchema();

    // Run the app
    LoggerService.info('Starting application UI...');
    runApp(const MyApp());
  } catch (e, stackTrace) {
    LoggerService.error(
        'Critical error during application startup', e, stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    LoggerService.info('Building root widget');

    return MultiProvider(
      providers: [
        // Auth provider must be first as others depend on it
        ChangeNotifierProvider(
          create: (_) {
            LoggerService.info('Initializing AuthProvider');
            return AuthProvider();
          },
        ),
        // Database provider depends on auth provider
        ChangeNotifierProxyProvider<AuthProvider, DatabaseProvider>(
          create: (context) {
            LoggerService.info(
                'Creating DatabaseProvider with AuthProvider dependency');
            return DatabaseProvider(context.read<AuthProvider>());
          },
          update: (context, auth, previous) {
            LoggerService.info(
                'Updating DatabaseProvider with new AuthProvider instance');
            return previous ?? DatabaseProvider(auth);
          },
        ),
        // Other providers
        ChangeNotifierProvider(
          create: (_) {
            LoggerService.info('Initializing ElectricianProvider');
            return ElectricianProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            LoggerService.info('Initializing HomeownerProvider');
            return HomeownerProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            LoggerService.info('Initializing JobProvider');
            return JobProvider(SupabaseConfig.client);
          },
        ),
      ],
      child: MaterialApp(
        title: 'ElectriConnect',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) {
            LoggerService.info('Rendering initial screen (SplashScreen)');
            return const SplashScreen();
          },
        ),
        onGenerateRoute: (settings) {
          LoggerService.info('Generating route for: ${settings.name}');

          switch (settings.name) {
            case '/homeowner/dashboard':
              return MaterialPageRoute(
                builder: (_) => const HomeownerMainScreen(),
              );
            case '/electrician/dashboard':
              return MaterialPageRoute(
                builder: (_) => const ElectricianMainScreen(),
              );
            case '/create-job':
              return MaterialPageRoute(
                builder: (_) => const CreateJobScreen(),
              );
            case '/electrician/edit-profile':
              return MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              );
            default:
              LoggerService.warning(
                  'Unknown route requested: ${settings.name}');
              return null;
          }
        },
      ),
    );
  }
}
