import 'package:flutter/material.dart';

class HomeownerProvider extends ChangeNotifier {
  // TODO: Replace mock data with real database integration
  // TODO: Implement proper data persistence
  // TODO: Add error handling and retry mechanisms
  // TODO: Implement proper state management for loading states
  // Reference implementation kept for structure:
  final List<String> _savedElectricians = [];
  final List<String> _activeJobs = [];

  List<String> get savedElectricians => _savedElectricians;
  List<String> get activeJobs => _activeJobs;

  // TODO: Implement proper database operations for adding/removing saved electricians
  void addSavedElectrician(String electricianId) {
    _savedElectricians.add(electricianId);
    notifyListeners();
  }

  // TODO: Implement proper job management with database operations
  void addActiveJob(String jobId) {
    _activeJobs.add(jobId);
    notifyListeners();
  }
}
