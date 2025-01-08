import 'package:flutter/material.dart';

class HomeownerProvider extends ChangeNotifier {
  // Mock data for now
  List<String> _savedElectricians = [];
  List<String> _activeJobs = [];

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
