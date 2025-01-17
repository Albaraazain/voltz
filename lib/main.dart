import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/services/logger_service.dart';
import 'core/config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/database_provider.dart';
import 'providers/electrician_provider.dart';
import 'providers/homeowner_provider.dart';
import 'providers/job_provider.dart';
import 'providers/electrician_stats_provider.dart';
import 'providers/availability_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/notification_provider.dart';
import 'features/common/screens/splash_screen.dart';
import 'features/homeowner/screens/homeowner_main_screen.dart';
import 'features/electrician/screens/electrician_main_screen.dart';
import 'features/homeowner/screens/create_job_screen.dart';
import 'features/electrician/screens/edit_profile_screen.dart';
import 'features/electrician/screens/manage_services_screen.dart';
import 'features/electrician/screens/reviews_screen.dart';
import 'features/electrician/screens/availability_settings_screen.dart';
import 'features/electrician/screens/payment_settings_screen.dart';
import 'features/common/screens/review_details_screen.dart';
import 'features/electrician/screens/job_details_screen.dart';
import 'features/homeowner/screens/direct_request_screen.dart';
import 'features/homeowner/screens/my_direct_requests_screen.dart';
import 'models/review_model.dart';
import 'models/job_model.dart';
import 'features/homeowner/screens/book_appointment_screen.dart';
import 'models/schedule_slot_model.dart';
import 'features/common/screens/notifications_screen.dart';
import 'features/homeowner/screens/notifications_screen.dart' as homeowner;
import 'features/electrician/screens/notification_settings_screen.dart'
    as electrician;
import 'features/electrician/screens/recent_jobs_screen.dart';

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
      anonKey: SupabaseConfig.supabaseServiceRoleKey,
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
        // Electrician provider depends on database provider
        ChangeNotifierProxyProvider<DatabaseProvider, ElectricianProvider>(
          create: (context) {
            LoggerService.info(
                'Creating ElectricianProvider with DatabaseProvider dependency');
            return ElectricianProvider(context.read<DatabaseProvider>());
          },
          update: (context, db, previous) {
            LoggerService.info(
                'Updating ElectricianProvider with new DatabaseProvider instance');
            return previous ?? ElectricianProvider(db);
          },
        ),
        // Homeowner provider depends on database provider
        ChangeNotifierProxyProvider<DatabaseProvider, HomeownerProvider>(
          create: (context) {
            LoggerService.info(
                'Creating HomeownerProvider with DatabaseProvider dependency');
            return HomeownerProvider(context.read<DatabaseProvider>());
          },
          update: (context, db, previous) {
            LoggerService.info(
                'Updating HomeownerProvider with new DatabaseProvider instance');
            return previous ?? HomeownerProvider(db);
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            LoggerService.info('Initializing JobProvider');
            return JobProvider(SupabaseConfig.client);
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            LoggerService.info('Initializing ElectricianStatsProvider');
            return ElectricianStatsProvider(SupabaseConfig.client);
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            LoggerService.info('Initializing AvailabilityProvider');
            return AvailabilityProvider(SupabaseConfig.client);
          },
        ),
        ChangeNotifierProxyProvider<AvailabilityProvider, ScheduleProvider>(
          create: (context) {
            LoggerService.info(
                'Creating ScheduleProvider with AvailabilityProvider dependency');
            return ScheduleProvider(
              SupabaseConfig.client,
            );
          },
          update: (context, availability, previous) {
            LoggerService.info(
                'Updating ScheduleProvider with new AvailabilityProvider instance');
            return previous ?? ScheduleProvider(SupabaseConfig.client);
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (context) {
            LoggerService.info('Creating NotificationProvider');
            final authProvider = context.read<AuthProvider>();
            return NotificationProvider(
              SupabaseConfig.client,
              authProvider.user?.id,
            );
          },
          update: (context, auth, previous) {
            LoggerService.info(
                'Updating NotificationProvider with new auth state');
            return NotificationProvider(
              SupabaseConfig.client,
              auth.user?.id,
            );
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
            case '/notifications':
              return MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              );
            case '/homeowner/notification-settings':
              return MaterialPageRoute(
                builder: (_) => const homeowner.NotificationsScreen(),
              );
            case '/electrician/notification-settings':
              return MaterialPageRoute(
                builder: (_) => const electrician.NotificationSettingsScreen(),
              );
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
            case '/electrician/manage-services':
              return MaterialPageRoute(
                builder: (_) => const ManageServicesScreen(),
              );
            case '/electrician/reviews':
              return MaterialPageRoute(
                builder: (_) => const ReviewsScreen(),
              );
            case '/electrician/availability':
              return MaterialPageRoute(
                builder: (_) => const AvailabilitySettingsScreen(),
              );
            case '/electrician/payment':
              return MaterialPageRoute(
                builder: (_) => const PaymentSettingsScreen(),
              );
            case '/electrician/recent-jobs':
              return MaterialPageRoute(
                builder: (_) => const RecentJobsScreen(),
              );
            case '/review-details':
              return MaterialPageRoute(
                builder: (_) => ReviewDetailsScreen(
                  review: settings.arguments as Review,
                ),
              );
            case '/electrician/job-details':
              return MaterialPageRoute(
                builder: (_) => JobDetailsScreen(
                  job: settings.arguments as Job,
                ),
              );
            case '/homeowner/direct-request':
              final args = settings.arguments as Map<String, String>;
              return MaterialPageRoute(
                builder: (_) => DirectRequestScreen(
                  electricianId: args['electricianId']!,
                  electricianName: args['electricianName']!,
                  jobId: args['jobId']!,
                ),
              );
            case '/homeowner/my-requests':
              return MaterialPageRoute(
                builder: (_) => const MyDirectRequestsScreen(),
              );
            case '/book_appointment':
              LoggerService.info('Handling /book_appointment route');
              try {
                if (settings.arguments == null) {
                  throw ArgumentError(
                      'No arguments provided for book_appointment route');
                }

                final args = settings.arguments as Map<String, dynamic>;
                LoggerService.debug('Route arguments: $args');

                if (!args.containsKey('electricianId')) {
                  throw ArgumentError(
                      'Missing electricianId in route arguments');
                }
                if (!args.containsKey('slot')) {
                  throw ArgumentError('Missing slot in route arguments');
                }

                final electricianId = args['electricianId'] as String;
                LoggerService.debug('Extracted electricianId: $electricianId');

                final slotData = args['slot'];
                LoggerService.debug('Raw slot data: $slotData');

                if (slotData is! Map<String, dynamic>) {
                  throw ArgumentError(
                      'Slot data is not in the correct format. Expected Map<String, dynamic>, got ${slotData.runtimeType}');
                }

                final slotJson = slotData;
                LoggerService.debug(
                    'Converting slot JSON to ScheduleSlot object: $slotJson');

                final slot = ScheduleSlot.fromJson(slotJson);
                LoggerService.debug(
                    'Successfully created ScheduleSlot object:\n'
                    'ID: ${slot.id}\n'
                    'Date: ${slot.date}\n'
                    'Time: ${slot.startTime} - ${slot.endTime}\n'
                    'Status: ${slot.status}');

                return MaterialPageRoute(
                  builder: (_) => BookAppointmentScreen(
                    electricianId: electricianId,
                    selectedSlot: slot,
                  ),
                );
              } catch (e, stackTrace) {
                LoggerService.error(
                  'Failed to create book appointment route',
                  e,
                  stackTrace,
                );
                // Return an error route
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Error'),
                      backgroundColor: Colors.red,
                    ),
                    body: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load appointment booking screen',
                              style: Theme.of(_).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              e.toString(),
                              style: Theme.of(_).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
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
