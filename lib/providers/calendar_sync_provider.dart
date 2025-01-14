import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../core/services/notification_service.dart';
import '../models/calendar_sync_model.dart';

class CalendarSyncProvider extends ChangeNotifier {
  final SupabaseClient _client;
  bool _isLoading = false;
  String? _error;
  List<CalendarSync> _syncedCalendars = [];
  bool _isSyncing = false;

  CalendarSyncProvider(this._client);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CalendarSync> get syncedCalendars => _syncedCalendars;
  bool get isSyncing => _isSyncing;

  // Load synced calendars for a user
  Future<void> loadSyncedCalendars(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('calendar_syncs')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      _syncedCalendars =
          response.map((json) => CalendarSync.fromJson(json)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Error loading synced calendars', e, stackTrace);
      _error = 'Failed to load synced calendars';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new calendar sync
  Future<void> addCalendarSync(CalendarSync sync) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('calendar_syncs')
          .insert(sync.toJson())
          .select()
          .single();

      final newSync = CalendarSync.fromJson(response);
      _syncedCalendars.add(newSync);

      // Start initial sync
      await _syncCalendar(newSync);

      await NotificationService.showNotification(
        title: 'Calendar Synced',
        body: 'Your calendar has been synced successfully',
        payload: 'calendar_sync_${newSync.id}',
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error adding calendar sync', e, stackTrace);
      _error = 'Failed to add calendar sync';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove a calendar sync
  Future<void> removeCalendarSync(String syncId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('calendar_syncs').delete().eq('id', syncId);
      _syncedCalendars.removeWhere((sync) => sync.id == syncId);

      await NotificationService.showNotification(
        title: 'Calendar Removed',
        body: 'Calendar sync has been removed',
        payload: 'calendar_sync_removed_$syncId',
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error removing calendar sync', e, stackTrace);
      _error = 'Failed to remove calendar sync';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sync a specific calendar
  Future<void> _syncCalendar(CalendarSync sync) async {
    try {
      _isSyncing = true;
      notifyListeners();

      // TODO: Implement calendar-specific sync logic based on provider
      switch (sync.provider) {
        case 'google':
          await _syncGoogleCalendar(sync);
          break;
        case 'outlook':
          await _syncOutlookCalendar(sync);
          break;
        case 'apple':
          await _syncAppleCalendar(sync);
          break;
        default:
          throw Exception('Unsupported calendar provider');
      }

      // Update last sync time
      await _client
          .from('calendar_syncs')
          .update({'last_synced_at': DateTime.now().toIso8601String()}).eq(
              'id', sync.id);
    } catch (e, stackTrace) {
      LoggerService.error('Error syncing calendar', e, stackTrace);
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Sync all calendars for a user
  Future<void> syncAllCalendars(String userId) async {
    try {
      _isSyncing = true;
      notifyListeners();

      for (final sync in _syncedCalendars) {
        if (sync.userId == userId) {
          await _syncCalendar(sync);
        }
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Provider-specific sync implementations
  Future<void> _syncGoogleCalendar(CalendarSync sync) async {
    // TODO: Implement Google Calendar sync
    // 1. Use Google Calendar API
    // 2. Handle OAuth flow
    // 3. Sync events bidirectionally
  }

  Future<void> _syncOutlookCalendar(CalendarSync sync) async {
    // TODO: Implement Outlook Calendar sync
    // 1. Use Microsoft Graph API
    // 2. Handle OAuth flow
    // 3. Sync events bidirectionally
  }

  Future<void> _syncAppleCalendar(CalendarSync sync) async {
    // TODO: Implement Apple Calendar sync
    // 1. Use EventKit framework
    // 2. Handle permissions
    // 3. Sync events bidirectionally
  }
}
