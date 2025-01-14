import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/job_model.dart';
import '../models/homeowner_model.dart';
import 'database_provider.dart';

class HomeownerProvider extends ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  final SupabaseClient _client = SupabaseConfig.client;

  List<String> _savedElectricians = [];
  List<Job> _activeJobs = [];
  bool _isLoading = false;

  HomeownerProvider(this._databaseProvider) {
    _initialize();
  }

  List<String> get savedElectricians => _savedElectricians;
  List<Job> get activeJobs => _activeJobs;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    await Future.wait([
      loadSavedElectricians(),
      loadActiveJobs(),
    ]);
  }

  Future<void> loadSavedElectricians() async {
    try {
      _isLoading = true;
      notifyListeners();

      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      final response = await _client
          .from('saved_electricians')
          .select('electrician_id')
          .eq('homeowner_id', homeownerId);

      _savedElectricians = List<String>.from(
        response.map((item) => item['electrician_id'] as String),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load saved electricians', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadActiveJobs() async {
    try {
      _isLoading = true;
      notifyListeners();

      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      final response = await _client
          .from('jobs')
          .select('''
            *,
            electrician:electricians (
              *,
              profile:profiles (*)
            )
          ''')
          .eq('homeowner_id', homeownerId)
          .neq('status', 'completed')
          .order('created_at', ascending: false);

      _activeJobs = response.map((job) => Job.fromJson(job)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load active jobs', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addSavedElectrician(String electricianId) async {
    try {
      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      await _client.from('saved_electricians').insert({
        'homeowner_id': homeownerId,
        'electrician_id': electricianId,
      });

      await loadSavedElectricians();
    } catch (e) {
      LoggerService.error('Failed to add saved electrician', e);
      rethrow;
    }
  }

  Future<void> removeSavedElectrician(String electricianId) async {
    try {
      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      await _client.from('saved_electricians').delete().match({
        'homeowner_id': homeownerId,
        'electrician_id': electricianId,
      });

      await loadSavedElectricians();
    } catch (e) {
      LoggerService.error('Failed to remove saved electrician', e);
      rethrow;
    }
  }

  Future<Job> createJob({
    required String title,
    required String description,
    required DateTime date,
    required double price,
    String? electricianId,
  }) async {
    try {
      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      final response = await _client
          .from('jobs')
          .insert({
            'title': title,
            'description': description,
            'status': 'pending',
            'date': date.toIso8601String(),
            'homeowner_id': homeownerId,
            'electrician_id': electricianId,
            'price': price,
          })
          .select()
          .single();

      final job = Job.fromJson(response);
      _activeJobs.insert(0, job);
      notifyListeners();
      return job;
    } catch (e) {
      LoggerService.error('Failed to create job', e);
      rethrow;
    }
  }

  Future<void> cancelJob(String jobId) async {
    try {
      await _client
          .from('jobs')
          .update({'status': 'cancelled'}).eq('id', jobId);

      await loadActiveJobs();
    } catch (e) {
      LoggerService.error('Failed to cancel job', e);
      rethrow;
    }
  }

  String getCurrentHomeownerId() {
    if (_databaseProvider.currentHomeowner == null) {
      throw Exception('No homeowner is currently logged in');
    }
    return _databaseProvider.currentHomeowner!.id;
  }
}
