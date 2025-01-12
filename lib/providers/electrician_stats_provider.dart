import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../services/logger_service.dart';
import '../utils/api_response.dart';

class ElectricianStats {
  final String id;
  final int todayJobs;
  final int newRequests;
  final double weeklyEarnings;
  final double rating;
  final List<MapEntry<String, double>> earningsData;
  final int unreadNotifications;
  final List<NotificationModel> notifications;

  ElectricianStats({
    required this.id,
    required this.todayJobs,
    required this.newRequests,
    required this.weeklyEarnings,
    required this.rating,
    required this.earningsData,
    required this.unreadNotifications,
    required this.notifications,
  });
}

class ElectricianStatsProvider extends ChangeNotifier {
  final SupabaseClient _supabaseClient;
  ApiResponse<ElectricianStats> _stats = ApiResponse.initial();
  String _selectedPeriod = 'week';

  ElectricianStatsProvider(this._supabaseClient);

  ApiResponse<ElectricianStats> get stats => _stats;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _stats.status == ApiStatus.loading;

  Future<void> loadStats(String electricianId) async {
    try {
      _stats = ApiResponse.loading();
      notifyListeners();

      LoggerService.debug('Loading stats for electrician: $electricianId');

      // Get today's jobs
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todaysJobsResponse = await _supabaseClient
          .from('jobs')
          .select()
          .eq('electrician_id', electricianId)
          .gte('date', todayStart.toIso8601String())
          .lt('date', todayEnd.toIso8601String());

      final todaysJobs = todaysJobsResponse.length;
      LoggerService.debug('Today\'s jobs: $todaysJobs');

      // Get new job requests
      final newRequestsResponse = await _supabaseClient
          .from('jobs')
          .select()
          .eq('electrician_id', electricianId)
          .eq('status', 'pending');

      final newRequests = newRequestsResponse.length;
      LoggerService.debug('New requests: $newRequests');

      // Get weekly earnings
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final weeklyEarningsResponse = await _supabaseClient
          .from('jobs')
          .select()
          .eq('electrician_id', electricianId)
          .eq('status', 'completed')
          .gte('date', weekStart.toIso8601String())
          .lt('date', weekEnd.toIso8601String());

      final weeklyEarnings = weeklyEarningsResponse.fold<double>(
        0,
        (sum, job) => sum + (job['price'] as num).toDouble(),
      );
      LoggerService.debug('Weekly earnings: \$$weeklyEarnings');

      // Get electrician rating
      final electricianResponse = await _supabaseClient
          .from('electricians')
          .select()
          .eq('id', electricianId)
          .single();

      final rating = (electricianResponse['rating'] as num?)?.toDouble() ?? 0.0;
      LoggerService.debug('Rating: $rating');

      // Get earnings data based on selected period
      final earningsData = await _getEarningsData(electricianId);
      LoggerService.debug('Earnings data loaded');

      // Get unread notifications count and recent notifications
      final notificationsResponse = await _supabaseClient
          .from('notifications')
          .select()
          .eq('electrician_id', electricianId)
          .order('created_at', ascending: false)
          .limit(10);

      final notifications = notificationsResponse
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      final unreadNotifications = notifications.where((n) => !n.read).length;
      LoggerService.debug('Unread notifications: $unreadNotifications');

      _stats = ApiResponse.completed(ElectricianStats(
        id: electricianId,
        todayJobs: todaysJobs,
        newRequests: newRequests,
        weeklyEarnings: weeklyEarnings,
        rating: rating,
        earningsData: earningsData,
        unreadNotifications: unreadNotifications,
        notifications: notifications,
      ));
    } catch (error, stackTrace) {
      LoggerService.error(
        'Error loading electrician stats',
        error: error,
        stackTrace: stackTrace,
      );
      _stats = ApiResponse.error(error.toString());
    }
    notifyListeners();
  }

  Future<List<MapEntry<String, double>>> _getEarningsData(
    String electricianId,
  ) async {
    final now = DateTime.now();
    late DateTime startDate;
    late DateTime endDate;
    late String groupByFormat;

    switch (_selectedPeriod) {
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 7));
        groupByFormat = 'Day';
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        groupByFormat = 'Week';
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year + 1, 1, 0);
        groupByFormat = 'Month';
        break;
      default:
        throw ArgumentError('Invalid period: $_selectedPeriod');
    }

    final response = await _supabaseClient
        .from('jobs')
        .select()
        .eq('electrician_id', electricianId)
        .eq('status', 'completed')
        .gte('date', startDate.toIso8601String())
        .lt('date', endDate.toIso8601String());

    final jobs = response as List;
    final Map<String, double> earnings = {};

    for (final job in jobs) {
      final date = DateTime.parse(job['date'] as String);
      String key;

      switch (groupByFormat) {
        case 'Day':
          key = '${date.month}/${date.day}';
          break;
        case 'Week':
          final weekNumber = ((date.day - 1) ~/ 7) + 1;
          key = 'Week $weekNumber';
          break;
        case 'Month':
          key = date.month.toString();
          break;
        default:
          throw ArgumentError('Invalid group by format: $groupByFormat');
      }

      earnings[key] = (earnings[key] ?? 0) + (job['price'] as num).toDouble();
    }

    return earnings.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  }

  void updatePeriod(String period) {
    if (_selectedPeriod != period) {
      _selectedPeriod = period;
      if (_stats.data != null) {
        loadStats(_stats.data!.id);
      }
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .update({'read': true}).eq('id', notificationId);

      if (_stats.data != null) {
        loadStats(_stats.data!.id);
      }
    } catch (error, stackTrace) {
      LoggerService.error(
        'Error marking notification as read',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
