import 'package:flutter/foundation.dart';
import '../core/database/database_helper.dart';
import '../core/services/logger_service.dart';
import '../models/job_model.dart';

class JobProvider with ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Job> getJobsByStatus(String status) {
    return _jobs.where((job) => job.status == status).toList();
  }

  Future<void> loadJobs(String homeownerId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      LoggerService.info('Loading jobs for homeowner: $homeownerId');
      final jobMaps = await _databaseHelper.getJobsByHomeowner(homeownerId);
      _jobs = jobMaps.map((map) => Job.fromMap(map)).toList();

      LoggerService.debug('Loaded ${_jobs.length} jobs');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load jobs', e, stackTrace);
      _error = 'Failed to load jobs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addJob(Job job) async {
    try {
      LoggerService.info('Adding new job: ${job.title}');
      await _databaseHelper.insertJob(job.toMap());
      _jobs.add(job);
      notifyListeners();
      LoggerService.debug('Job added successfully: ${job.id}');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to add job', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateStatus(String jobId, String newStatus) async {
    try {
      LoggerService.info('Updating job status: $jobId to $newStatus');
      await _databaseHelper.updateJobStatus(jobId, newStatus);

      final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
      if (jobIndex != -1) {
        _jobs[jobIndex] = Job(
          id: _jobs[jobIndex].id,
          title: _jobs[jobIndex].title,
          description: _jobs[jobIndex].description,
          status: newStatus,
          date: _jobs[jobIndex].date,
          electricianId: _jobs[jobIndex].electricianId,
          homeownerId: _jobs[jobIndex].homeownerId,
          price: _jobs[jobIndex].price,
        );
        notifyListeners();
      }

      LoggerService.debug('Job status updated successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update job status', e, stackTrace);
      rethrow;
    }
  }

  // TODO: Implement job search filters (by date, price range, location radius)
  // TODO: Add job scheduling conflict detection
  // TODO: Implement job cancellation policy and refund process
  // TODO: Add emergency job request handling
  // TODO: Implement job progress tracking and milestones
  // TODO: Add job cost estimation calculator
  // TODO: Implement recurring job scheduling
  // TODO: Add multi-location job support
  // TODO: Implement job completion verification process
  // TODO: Add dispute resolution system
}
