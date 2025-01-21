import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/common/screens/notifications_screen.dart';
import '../../features/common/screens/reviews_screen.dart';
import '../../features/electrician/screens/dashboard_screen.dart';
import '../../features/electrician/screens/incoming_requests_screen.dart';
import '../../features/electrician/screens/job_details_screen.dart';
import '../../features/electrician/screens/manage_services_screen.dart';
import '../../features/homeowner/screens/all_electricians_screen.dart';
import '../../features/homeowner/screens/category_services_screen.dart';
import '../../features/homeowner/screens/service_details_screen.dart';
import '../../features/homeowner/screens/create_job_screen.dart';
import '../../features/homeowner/screens/electrician_profile_view_screen.dart';
import '../../features/homeowner/screens/home_screen.dart';
import '../../features/homeowner/screens/slot_selection_screen.dart';
import '../../features/homeowner/screens/homeowner_main_screen.dart';
import '../../features/electrician/screens/electrician_main_screen.dart';
import '../../features/electrician/screens/edit_profile_screen.dart';
import '../../features/electrician/screens/availability_settings_screen.dart';
import '../../features/electrician/screens/payment_settings_screen.dart';
import '../../features/common/screens/review_details_screen.dart';
import '../../features/homeowner/screens/direct_request_screen.dart';
import '../../features/homeowner/screens/my_direct_requests_screen.dart';
import '../../features/homeowner/screens/book_appointment_screen.dart';
import '../../features/homeowner/screens/browse_electricians_map_screen.dart';
import '../../features/homeowner/screens/notifications_screen.dart'
    as homeowner;
import '../../features/electrician/screens/notification_settings_screen.dart'
    as electrician;
import '../../features/electrician/screens/recent_jobs_screen.dart';
import '../../models/service_category_model.dart';
import '../../models/job_model.dart';
import '../../models/review_model.dart';
import '../../models/service_model.dart';
import '../../core/services/logger_service.dart';
import '../../features/homeowner/screens/find_professional_map_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    LoggerService.info('Generating route for: ${settings.name}');

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const HomeownerHomeScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case '/reviews':
        final Map<String, dynamic> args =
            settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewsScreen(
            userId: args['userId'] as String,
            userName: args['userName'] as String,
            canRespond: args['canRespond'] as bool? ?? false,
          ),
        );
      case '/browse_electricians':
        return MaterialPageRoute(builder: (_) => const AllElectriciansScreen());
      case '/electrician_profile':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) =>
              ElectricianProfileViewScreen(electricianId: args['id']!),
        );
      case '/slot_selection':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) =>
              SlotSelectionScreen(electricianId: args['electricianId']!),
        );
      case '/electrician/dashboard':
        return MaterialPageRoute(builder: (_) => const ElectricianMainScreen());
      case '/electrician/incoming_requests':
        return MaterialPageRoute(
            builder: (_) => const IncomingRequestsScreen());
      case '/electrician/job_details':
        final Job job = settings.arguments as Job;
        return MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job));
      case '/electrician/manage-services':
        return MaterialPageRoute(builder: (_) => const ManageServicesScreen());
      case '/category_services':
        final ServiceCategory category = settings.arguments as ServiceCategory;
        return MaterialPageRoute(
            builder: (_) => CategoryServicesScreen(category: category));
      case '/service_details':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ServiceDetailsScreen(
            service: args['service'] as Service,
            category: args['category'] as ServiceCategory,
          ),
        );
      case '/create_job':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CreateJobScreen(
            service: args['service'] as Service,
            category: args['category'] as ServiceCategory,
          ),
        );
      case '/homeowner/dashboard':
        return MaterialPageRoute(builder: (_) => const HomeownerMainScreen());
      case '/homeowner/notification-settings':
        return MaterialPageRoute(
            builder: (_) => const homeowner.NotificationsScreen());
      case '/electrician/notification-settings':
        return MaterialPageRoute(
            builder: (_) => const electrician.NotificationSettingsScreen());
      case '/electrician/edit-profile':
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case '/electrician/reviews':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewsScreen(
            userId: args['userId'] as String,
            userName: args['userName'] as String,
            canRespond: args['canRespond'] as bool? ?? false,
          ),
        );
      case '/electrician/availability':
        return MaterialPageRoute(
            builder: (_) => const AvailabilitySettingsScreen());
      case '/electrician/payment':
        return MaterialPageRoute(builder: (_) => const PaymentSettingsScreen());
      case '/electrician/recent-jobs':
        return MaterialPageRoute(builder: (_) => const RecentJobsScreen());
      case '/review-details':
        return MaterialPageRoute(
          builder: (_) =>
              ReviewDetailsScreen(review: settings.arguments as Review),
        );
      case '/direct_request':
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => DirectRequestScreen(
            electricianId: args['electricianId']!,
            electricianName: args['electricianName']!,
          ),
        );
      case '/homeowner/my-requests':
        return MaterialPageRoute(
            builder: (_) => const MyDirectRequestsScreen());
      case '/book_appointment':
        try {
          if (settings.arguments == null) {
            throw ArgumentError(
                'No arguments provided for book_appointment route');
          }
          final args = settings.arguments as Map<String, dynamic>;
          if (!args.containsKey('electricianId')) {
            throw ArgumentError('Missing electricianId in route arguments');
          }
          return MaterialPageRoute(
            builder: (_) => BookAppointmentScreen(
              electricianId: args['electricianId'] as String,
              selectedSlot: args['slot'],
            ),
          );
        } catch (e, stackTrace) {
          LoggerService.error(
              'Failed to create book appointment route', e, stackTrace);
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(
                  title: const Text('Error'), backgroundColor: Colors.red),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load appointment booking screen',
                        style: Theme.of(_).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.toString(),
                        style: Theme.of(_)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      case '/browse_map':
        return MaterialPageRoute(
          builder: (_) => const BrowseElectriciansMapScreen(),
        );
      case '/find_professional_map':
        if (settings.arguments is! Map<String, dynamic>) {
          throw Exception('Invalid arguments for FindProfessionalMapScreen');
        }
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => FindProfessionalMapScreen(
            service: args['service'],
            hours: args['hours'],
            maxBudgetPerHour: args['maxBudgetPerHour'],
            scheduledDate: args['scheduledDate'],
            scheduledTime: args['scheduledTime'],
            additionalNotes: args['additionalNotes'],
          ),
        );
      default:
        LoggerService.warning('Unknown route requested: ${settings.name}');
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
