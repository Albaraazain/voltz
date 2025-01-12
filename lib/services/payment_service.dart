import '../models/job_model.dart';
import 'logger_service.dart';

class PaymentService {
  // Simulated payment processing
  static Future<Map<String, dynamic>> processPayment({
    required String jobId,
    required double amount,
    String currency = 'USD',
  }) async {
    try {
      LoggerService.info(
          'Processing payment for job: $jobId, amount: \$$amount');

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Hardcoded successful payment response
      return {
        'id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
        'status': Job.PAYMENT_STATUS_COMPLETED,
        'amount': amount,
        'currency': currency,
        'processed_at': DateTime.now().toIso8601String(),
        'payment_method': 'card',
        'card_last4': '4242',
        'receipt_url': 'https://example.com/receipt',
      };
    } catch (e, stackTrace) {
      LoggerService.error(
        'Payment processing failed',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'id': 'pay_${DateTime.now().millisecondsSinceEpoch}',
        'status': Job.PAYMENT_STATUS_FAILED,
        'error': e.toString(),
        'amount': amount,
        'currency': currency,
        'processed_at': DateTime.now().toIso8601String(),
      };
    }
  }

  // Simulated payment verification
  static Future<bool> verifyPayment(String paymentId) async {
    try {
      LoggerService.info('Verifying payment: $paymentId');

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Hardcoded verification (always returns true)
      return true;
    } catch (e, stackTrace) {
      LoggerService.error(
        'Payment verification failed',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  // Simulated refund processing
  static Future<Map<String, dynamic>> processRefund({
    required String jobId,
    required String paymentId,
    required double amount,
  }) async {
    try {
      LoggerService.info('Processing refund for payment: $paymentId');

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Hardcoded successful refund response
      return {
        'id': 'ref_${DateTime.now().millisecondsSinceEpoch}',
        'status': Job.PAYMENT_STATUS_REFUNDED,
        'amount': amount,
        'processed_at': DateTime.now().toIso8601String(),
        'original_payment_id': paymentId,
      };
    } catch (e, stackTrace) {
      LoggerService.error(
        'Refund processing failed',
        error: e,
        stackTrace: stackTrace,
      );
      return {
        'id': 'ref_${DateTime.now().millisecondsSinceEpoch}',
        'status': Job.PAYMENT_STATUS_FAILED,
        'error': e.toString(),
        'amount': amount,
        'original_payment_id': paymentId,
      };
    }
  }
}
