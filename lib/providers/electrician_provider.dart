import 'package:flutter/material.dart';

class ElectricianProvider extends ChangeNotifier {
  // Mock data for now
  bool _isAvailable = true;
  String _currentStatus = 'Available';

  bool get isAvailable => _isAvailable;
  String get currentStatus => _currentStatus;

  void updateAvailability(bool available) {
    _isAvailable = available;
    _currentStatus = available ? 'Available' : 'Unavailable';
    notifyListeners();
  }
}
