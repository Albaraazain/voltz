import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../models/async_value.dart';
import '../models/electrician_stats.dart';

class ElectricianStatsProvider extends ChangeNotifier {
  final SupabaseClient _client;
  AsyncValue<ElectricianStats> _stats = const AsyncValue.loading();
  String _selectedPeriod = 'week';
  bool _isLoading = false;
  int _retryCount = 0;
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  ElectricianStatsProvider(this._client);

  AsyncValue<ElectricianStats> get stats => _stats;
  String get selectedPeriod => _selectedPeriod;
  bool get isLoading => _isLoading;

  Future<void> loadStats(String electricianId) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _stats = const AsyncValue.loading();
      notifyListeners();

      LoggerService.debug(
          'Starting loadStats for electricianId: $electricianId');

      // Load today's jobs
      LoggerService.debug('Loading today\'s jobs...');
      final todayJobsResponse = await _client
          .from('jobs')
          .select()
          .eq('electrician_id', electricianId)
          .gte('date', DateTime.now().toIso8601String().substring(0, 10));
      final todayJobs = (todayJobsResponse as List).length;
      LoggerService.debug('Today\'s jobs count: $todayJobs');

      // Load new requests
      LoggerService.debug('Loading new requests...');
      final newRequestsResponse = await _client
          .from('jobs')
          .select()
          .eq('electrician_id', electricianId)
          .eq('status', 'PENDING')
          .gte('date', DateTime.now().toIso8601String().substring(0, 10));
      final newRequests = (newRequestsResponse as List).length;
      LoggerService.debug('New requests count: $newRequests');

      // Load weekly earnings
      LoggerService.debug('Loading weekly earnings...');
      final weekStart = DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - 1),
      );
      final weeklyEarnings = await _client
          .from('jobs')
          .select('price')
          .eq('electrician_id', electricianId)
          .eq('status', 'completed')
          .gte('date', weekStart.toIso8601String());

      final weeklyTotal = (weeklyEarnings as List).fold<double>(
        0,
        (sum, job) => sum + (job['price'] as num).toDouble(),
      );
      LoggerService.debug('Weekly earnings total: $weeklyTotal');

      // Load rating
      LoggerService.debug('Loading ratings...');
      final reviews = await _client
          .from('reviews')
          .select('rating')
          .eq('electrician_id', electricianId);

      final rating = (reviews as List).isEmpty
          ? 0.0
          : reviews.fold<double>(
                0,
                (sum, review) => sum + (review['rating'] as num).toDouble(),
              ) /
              reviews.length;
      LoggerService.debug('Average rating: $rating');

      // Load earnings data based on period
      LoggerService.debug('Loading earnings data for period: $_selectedPeriod');
      final earningsData = await _loadEarningsData(electricianId);
      LoggerService.debug(
          'Earnings data points loaded: ${earningsData.length}');

      // Load unread notifications
      LoggerService.debug('Loading unread notifications...');
      final unreadNotificationsResponse = await _client
          .from('notifications')
          .select()
          .eq('profile_id', electricianId)
          .eq('read', false);
      final unreadNotifications = (unreadNotificationsResponse as List).length;
      LoggerService.debug('Unread notifications count: $unreadNotifications');

      _stats = AsyncValue.data(
        ElectricianStats(
          id: electricianId,
          todayJobs: todayJobs,
          newRequests: newRequests,
          weeklyEarnings: weeklyTotal,
          rating: rating,
          earningsData: earningsData,
          unreadNotifications: unreadNotifications,
        ),
      );

      _isLoading = false;
      _retryCount = 0;
      LoggerService.debug('Successfully loaded all electrician stats');
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load electrician stats', e, stackTrace);

      if (_retryCount < maxRetries) {
        _retryCount++;
        LoggerService.debug(
            'Retrying load stats (attempt $_retryCount of $maxRetries)');
        _isLoading = false;
        notifyListeners();
        await Future.delayed(retryDelay);
        return loadStats(electricianId);
      }

      _isLoading = false;
      _stats = AsyncValue.error(e);
      notifyListeners();
      rethrow;
    }
  }

  Future<List<EarningsDataPoint>> _loadEarningsData(
      String electricianId) async {
    final now = DateTime.now();
    DateTime startDate;
    int points;

    switch (_selectedPeriod) {
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        points = 7;
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        points = 4;
        break;
      case 'year':
        startDate = DateTime(now.year, 1, 1);
        points = 12;
        break;
      default:
        throw Exception('Invalid period: $_selectedPeriod');
    }

    final earnings = await _client
        .from('jobs')
        .select('date, price')
        .eq('electrician_id', electricianId)
        .eq('status', 'completed')
        .gte('date', startDate.toIso8601String())
        .order('date');

    final data = List<EarningsDataPoint>.generate(
      points,
      (index) => EarningsDataPoint(
        index: index,
        value: 0,
      ),
    );

    for (final job in earnings) {
      final date = DateTime.parse(job['date']);
      final price = (job['price'] as num).toDouble();
      int index;

      switch (_selectedPeriod) {
        case 'week':
          index = date.difference(startDate).inDays;
          break;
        case 'month':
          index = ((date.day - 1) / 7).floor();
          break;
        case 'year':
          index = date.month - 1;
          break;
        default:
          continue;
      }

      if (index >= 0 && index < points) {
        data[index] = EarningsDataPoint(
          index: index,
          value: data[index].value + price,
        );
      }
    }

    return data;
  }

  Future<void> updatePeriod(String period) async {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();

    if (_stats.hasData) {
      final electricianId = _stats.data!.id;
      await loadStats(electricianId);
    }
  }
}
