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

      await _supabase.from('jobs').update(updateData).match({'id': jobId});

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

      await _supabase.from('jobs').update(updateData).match({'id': jobId});

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

  Future<void> loadJobs(String userId, {bool isElectrician = false}) async {
    try {
      LoggerService.info(
          'Loading jobs for ${isElectrician ? 'electrician' : 'homeowner'}: $userId');
      _jobs = ApiResponse.loading();
      notifyListeners();

      var query = _supabase.from('jobs').select('''
            *,
            homeowner:homeowners (
              *,
              profile:profiles (*)
            ),
            electrician:electricians (
              *,
              profile:profiles (*)
            )
          ''');

      if (isElectrician) {
        // For electricians, show:
        // 1. Jobs assigned to them with status in_progress
        // 2. Unassigned jobs with status pending
        query = query.or(
            'and(electrician_id.eq.$userId,status.eq.${Job.STATUS_IN_PROGRESS}),and(electrician_id.is.null,status.eq.${Job.STATUS_PENDING})');
      } else {
        // For homeowners, show all their jobs except cancelled ones
        query = query
            .eq('homeowner_id', userId)
            .neq('status', Job.STATUS_CANCELLED);
      }

      final response = await query.order('created_at', ascending: false);

      final jobsList =
          (response as List).map((job) => Job.fromJson(job)).toList();

      LoggerService.debug(
          'Raw jobs response: ${response.map((j) => '${j['id']}: ${j['status']}, electrician_id: ${j['electrician_id']}').join(', ')}');

      _jobs = ApiResponse.success(jobsList);
      LoggerService.debug(
          'Loaded ${jobsList.length} jobs with statuses: ${jobsList.map((j) => '${j.id}: ${j.status}, electrician: ${j.electricianId}').join(', ')}');
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

  Future<void> updateJobStatus(String jobId, String newStatus,
      {String? electricianId}) async {
    try {
      LoggerService.info(
          'Updating job status: $jobId to $newStatus (electricianId: $electricianId)');

      if (!Job.isValidStatus(newStatus)) {
        throw Exception('Invalid job status: $newStatus');
      }

      final updateData = {
        'status': newStatus,
        if (newStatus == Job.STATUS_IN_PROGRESS && electricianId != null)
          'electrician_id': electricianId,
      };

      LoggerService.debug('Updating job with data: $updateData');

      // First fetch the current job to ensure it exists and we have access
      final currentJob =
          await _supabase.from('jobs').select().eq('id', jobId).single();

      if (currentJob == null) {
        throw Exception('Job not found: $jobId');
      }

      // Then perform the update
      final response = await _supabase
          .from('jobs')
          .update(updateData)
          .eq('id', jobId)
          .select()
          .single();

      // Update local state
      if (_jobs.hasData && _jobs.data != null) {
        final updatedJobs = _jobs.data!.map((job) {
          if (job.id == jobId) {
            final updatedJob = Job.fromJson(response);
            LoggerService.debug(
                'Updated job ${job.id} from status ${job.status} to ${updatedJob.status}');
            return updatedJob;
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

  Future<void> acceptJob(String jobId, String electricianId) async {
    try {
      LoggerService.info(
          'Accepting job: $jobId by electrician: $electricianId');

      // When accepting a job, we set it to in_progress and assign the electrician
      await updateJobStatus(jobId, Job.STATUS_IN_PROGRESS,
          electricianId: electricianId);

      // Add a small delay to ensure the database has processed the update
      await Future.delayed(const Duration(milliseconds: 500));

      // Refresh jobs list to update UI
      await loadJobs(electricianId, isElectrician: true);
    } catch (error, stackTrace) {
      LoggerService.error('Failed to accept job', error, stackTrace);
      rethrow;
    }
  }

  Future<void> declineJob(String jobId, String electricianId) async {
    try {
      LoggerService.info(
          'Declining job: $jobId by electrician: $electricianId');

      // When declining, we don't update electrician_id so other electricians can still see it
      await updateJobStatus(jobId, Job.STATUS_CANCELLED);

      // Refresh jobs list to update UI
      await loadJobs(electricianId, isElectrician: true);
    } catch (error, stackTrace) {
      LoggerService.error('Failed to decline job', error, stackTrace);
      rethrow;
    }
  }

  // Helper method to get jobs by type
  List<Job> getJobsByType(String type, String electricianId) {
    if (!_jobs.hasData || _jobs.data == null) return [];

    LoggerService.debug('Getting jobs for type: $type');
    return _jobs.data!.where((job) {
      if (type == 'new') {
        // Show pending jobs that are either unassigned or assigned to this electrician
        final isPending = job.status == Job.STATUS_PENDING;
        final isUnassigned = job.electricianId == null;
        final isAssignedToMe = job.electricianId == electricianId;

        LoggerService.debug(
            'Filtering job ${job.id} - status: ${job.status}, electricianId: ${job.electricianId}, isPending: $isPending, isUnassigned: $isUnassigned, isAssignedToMe: $isAssignedToMe');

        return isPending && (isUnassigned || isAssignedToMe);
      } else {
        // Show in_progress jobs assigned to this electrician
        final isInProgress = job.status == Job.STATUS_IN_PROGRESS;
        final isAssignedToMe = job.electricianId == electricianId;

        LoggerService.debug(
            'Filtering job ${job.id} - status: ${job.status}, electricianId: ${job.electricianId}, isInProgress: $isInProgress, isAssignedToMe: $isAssignedToMe');

        return isInProgress && isAssignedToMe;
      }
    }).toList();
  }
}
