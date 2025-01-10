enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
}

enum PaymentMethod {
  creditCard,
  debitCard,
  bankTransfer,
  wallet,
}

class PaymentModel {
  final String id;
  final String jobId;
  final String userId;
  final String electricianId;
  final double amount;
  final DateTime timestamp;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final String? failureReason;

  PaymentModel({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.electricianId,
    required this.amount,
    required this.timestamp,
    required this.status,
    required this.method,
    this.transactionId,
    this.failureReason,
  });
}

class PaymentMethodModel {
  final String id;
  final String userId;
  final PaymentMethod type;
  final String last4;
  final String brand;
  final String? expiryMonth;
  final String? expiryYear;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.last4,
    required this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
  });
}

// TODO: Implement split payment support
// TODO: Add multiple currency support
// TODO: Implement automatic recurring payments
// TODO: Add payment dispute handling
// TODO: Implement partial refund functionality
// TODO: Add invoice generation system
// TODO: Implement service fee calculation
// TODO: Add tax calculation and reporting
// TODO: Implement payment gateway integration (Stripe, PayPal)
// TODO: Add payment analytics and reporting
