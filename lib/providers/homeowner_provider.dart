import 'package:flutter/material.dart';

class HomeownerProvider extends ChangeNotifier {
  // Mock data for now
  final List<String> _savedElectricians = [];
  final List<String> _activeJobs = [];

  List<String> get savedElectricians => _savedElectricians;
  List<String> get activeJobs => _activeJobs;

  void addSavedElectrician(String electricianId) {
    _savedElectricians.add(electricianId);
    notifyListeners();
  }

  void addActiveJob(String jobId) {
    _activeJobs.add(jobId);
    notifyListeners();
  }
}
