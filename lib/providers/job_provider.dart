import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/api_response.dart';
import '../models/job_model.dart';
import '../core/services/logger_service.dart';

class JobProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  ApiResponse<List<Job>> _jobs = ApiResponse.initial();

  JobProvider(this._supabase);

  ApiResponse<List<Job>> get jobs => _jobs;
  bool get isLoading => _jobs.status == ApiStatus.loading;
  dynamic get error => _jobs.error;

  List<Job> getJobsByStatus(String status) {
    if (!_jobs.hasData || _jobs.data == null) return [];
    return _jobs.data!.where((job) => job.status == status).toList();
  }

  Future<void> loadJobs(String homeownerId) async {
    try {
      LoggerService.info('Loading jobs for homeowner: $homeownerId');
      _jobs = ApiResponse.loading();
      notifyListeners();

      final response = await _supabase
          .from('jobs')
          .select()
          .eq('homeowner_id', homeownerId)
          .order('created_at', ascending: false);

      final jobsList =
          (response as List).map((job) => Job.fromJson(job)).toList();

      _jobs = ApiResponse.success(jobsList);
      LoggerService.debug('Loaded ${jobsList.length} jobs');
    } catch (error, stackTrace) {
      LoggerService.error('Failed to load jobs', error, stackTrace);
      _jobs = ApiResponse.error(error, stackTrace);
    }
    notifyListeners();
  }

  Future<void> addJob(Job job) async {
    try {
      LoggerService.info('Adding new job: ${job.title}');

      final jobData = job.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');

      final response =
          await _supabase.from('jobs').insert(jobData).select().single();

      if (_jobs.hasData && _jobs.data != null) {
        final updatedJobs = List<Job>.from(_jobs.data!)
          ..insert(0, Job.fromJson(response));
        _jobs = ApiResponse.success(updatedJobs);
        notifyListeners();
      }

      LoggerService.debug('Job added successfully');
    } catch (error, stackTrace) {
      LoggerService.error('Failed to add job', error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    try {
      LoggerService.info('Updating job status: $jobId to $newStatus');

      await _supabase
          .from('jobs')
          .update({'status': newStatus}).eq('id', jobId);

      if (_jobs.hasData && _jobs.data != null) {
        final updatedJobs = _jobs.data!.map((job) {
          if (job.id == jobId) {
            return job.copyWith(status: newStatus);
          }
          return job;
        }).toList();
        _jobs = ApiResponse.success(updatedJobs);
        notifyListeners();
      }

      LoggerService.debug('Job status updated successfully');
    } catch (error, stackTrace) {
      LoggerService.error('Failed to update job status', error, stackTrace);
      rethrow;
    }
  }
}
