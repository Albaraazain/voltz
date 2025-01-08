import 'package:flutter/foundation.dart';
import '../models/payment_model.dart';

class PaymentProvider with ChangeNotifier {
  final List<PaymentMethodModel> _paymentMethods = [];
  final List<PaymentModel> _transactions = [];
  PaymentMethodModel? _selectedPaymentMethod;

  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  List<PaymentModel> get transactions => _transactions;
  PaymentMethodModel? get selectedPaymentMethod => _selectedPaymentMethod;

  Future<void> addPaymentMethod(PaymentMethodModel method) async {
    _paymentMethods.add(method);
    if (_paymentMethods.length == 1 || method.isDefault) {
      _selectedPaymentMethod = method;
    }
    notifyListeners();
  }

  Future<void> removePaymentMethod(String methodId) async {
    _paymentMethods.removeWhere((method) => method.id == methodId);
    if (_selectedPaymentMethod?.id == methodId) {
      _selectedPaymentMethod = _paymentMethods.isNotEmpty
          ? _paymentMethods.first
          : null;
    }
    notifyListeners();
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    for (var method in _paymentMethods) {
      if (method.id == methodId) {
        _selectedPaymentMethod = method;
        break;
      }
    }
    notifyListeners();
  }

  Future<PaymentModel> processPayment({
    required String jobId,
    required String userId,
    required String electricianId,
    required double amount,
  }) async {
    if (_selectedPaymentMethod == null) {
      throw Exception('No payment method selected');
    }

    // TODO: Implement actual payment processing
    final payment = PaymentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      jobId: jobId,
      userId: userId,
      electricianId: electricianId,
      amount: amount,
      timestamp: DateTime.now(),
      status: PaymentStatus.completed,
      method: _selectedPaymentMethod!.type,
      transactionId: 'mock_transaction_${DateTime.now().millisecondsSinceEpoch}',
    );

    _transactions.add(payment);
    notifyListeners();
    return payment;
  }
}