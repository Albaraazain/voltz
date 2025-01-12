import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/utils/api_response.dart';
import '../models/job_model.dart';
import '../core/services/logger_service.dart';

class JobProvider extends ChangeNotifier {
  final SupabaseClient _supabase;
  ApiResponse<List<Job>> _jobs = ApiResponse.initial();

  // TODO: Add real-time job status updates (Requires: Supabase realtime subscription)
  // TODO: Add job matching algorithm (Requires: AI/ML service integration)
  // TODO: Add job scheduling system (Requires: Calendar service)
  // TODO: Add emergency job handling (Requires: Emergency response system)
  // TODO: Add job progress tracking (Requires: Progress tracking system)
  // TODO: Add job chat/messaging system (Requires: Chat service)
  // TODO: Add job location tracking (Requires: Location service)
  // TODO: Add job cost estimation (Requires: Pricing engine)
  // TODO: Add job materials management (Requires: Inventory system)
  // TODO: Add job review system (Requires: Review service)
  // TODO: Add dispute resolution system (Requires: Support system)

  JobProvider(this._supabase);

  ApiResponse<List<Job>> get jobs => _jobs;
  bool get isLoading => _jobs.status == ApiStatus.loading;
  dynamic get error => _jobs.error;

  List<Job> getJobsByStatus(String status) {
    if (!_jobs.hasData || _jobs.data == null) return [];
    return _jobs.data!.where((job) => job.status == status).toList();
  }

  List<Job> getJobsByPaymentStatus(String paymentStatus) {
    if (!_jobs.hasData || _jobs.data == null) return [];
    return _jobs.data!
        .where((job) => job.paymentStatus == paymentStatus)
        .toList();
  }

  List<Job> getJobsByVerificationStatus(String verificationStatus) {
    if (!_jobs.hasData || _jobs.data == null) return [];
    return _jobs.data!
        .where((job) => job.verificationStatus == verificationStatus)
        .toList();
  }

  Future<void> updateJobPaymentStatus(
    String jobId,
    String newStatus, {
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      LoggerService.info('Updating job payment status: $jobId to $newStatus');

      if (!Job.isValidPaymentStatus(newStatus)) {
        throw Exception('Invalid payment status: $newStatus');
      }

      final updateData = {
        'payment_status': newStatus,
        if (paymentDetails != null) 'payment_details': paymentDetails,
      };

      await _supabase.from('jobs').update(updateData).eq('id', jobId);

      if (_jobs.hasData && _jobs.data != null) {
        final updatedJobs = _jobs.data!.map((job) {
          if (job.id == jobId) {
            return job.copyWith(
              paymentStatus: newStatus,
              paymentDetails: paymentDetails,
            );
          }
          return job;
        }).toList();
        _jobs = ApiResponse.success(updatedJobs);
        notifyListeners();
      }

      LoggerService.debug('Job payment status updated successfully');
    } catch (error, stackTrace) {
      LoggerService.error(
          'Failed to update job payment status', error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateJobVerificationStatus(
    String jobId,
    String newStatus, {
    Map<String, dynamic>? verificationDetails,
  }) async {
    try {
      LoggerService.info(
          'Updating job verification status: $jobId to $newStatus');

      if (!Job.isValidVerificationStatus(newStatus)) {
        throw Exception('Invalid verification status: $newStatus');
      }

      final updateData = {
        'verification_status': newStatus,
        if (verificationDetails != null)
          'verification_details': verificationDetails,
      };

      await _supabase.from('jobs').update(updateData).eq('id', jobId);

      if (_jobs.hasData && _jobs.data != null) {
        final updatedJobs = _jobs.data!.map((job) {
          if (job.id == jobId) {
            return job.copyWith(
              verificationStatus: newStatus,
              verificationDetails: verificationDetails,
            );
          }
          return job;
        }).toList();
        _jobs = ApiResponse.success(updatedJobs);
        notifyListeners();
      }

      LoggerService.debug('Job verification status updated successfully');
    } catch (error, stackTrace) {
      LoggerService.error(
          'Failed to update job verification status', error, stackTrace);
      rethrow;
    }
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
