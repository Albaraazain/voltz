class Job {
  // Payment status constants
  static const String PAYMENT_STATUS_PENDING = 'payment_pending';
  static const String PAYMENT_STATUS_PROCESSING = 'payment_processing';
  static const String PAYMENT_STATUS_COMPLETED = 'payment_completed';
  static const String PAYMENT_STATUS_FAILED = 'payment_failed';
  static const String PAYMENT_STATUS_REFUNDED = 'payment_refunded';

  // Verification status constants
  static const String VERIFICATION_STATUS_PENDING = 'verification_pending';
  static const String VERIFICATION_STATUS_APPROVED = 'verification_approved';
  static const String VERIFICATION_STATUS_REJECTED = 'verification_rejected';

  static const String STATUS_ACTIVE = 'active';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_CANCELLED = 'cancelled';
  static const String STATUS_IN_PROGRESS = 'in_progress';
  static const String STATUS_PENDING = 'pending';

  static const double MIN_PRICE = 20.0;
  static const double MAX_PRICE = 10000.0;

  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime date;
  final String? electricianId;
  final String homeownerId;
  final double price;
  final DateTime createdAt;
  final String? paymentStatus;
  final String? verificationStatus;
  final Map<String, dynamic>? paymentDetails;
  final Map<String, dynamic>? verificationDetails;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    this.electricianId,
    required this.homeownerId,
    required this.price,
    required this.createdAt,
    this.paymentStatus,
    this.verificationStatus,
    this.paymentDetails,
    this.verificationDetails,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'date': date.toIso8601String(),
      'electrician_id': electricianId,
      'homeowner_id': homeownerId,
      'price': price,
      'created_at': createdAt.toIso8601String(),
      'payment_status': paymentStatus,
      'verification_status': verificationStatus,
      'payment_details': paymentDetails,
      'verification_details': verificationDetails,
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      date: DateTime.parse(json['date']),
      electricianId: json['electrician_id'],
      homeownerId: json['homeowner_id'],
      price: json['price'].toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      paymentStatus: json['payment_status'],
      verificationStatus: json['verification_status'],
      paymentDetails: json['payment_details'],
      verificationDetails: json['verification_details'],
    );
  }

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    DateTime? date,
    String? electricianId,
    String? homeownerId,
    double? price,
    DateTime? createdAt,
    String? paymentStatus,
    String? verificationStatus,
    Map<String, dynamic>? paymentDetails,
    Map<String, dynamic>? verificationDetails,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      date: date ?? this.date,
      electricianId: electricianId ?? this.electricianId,
      homeownerId: homeownerId ?? this.homeownerId,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      verificationDetails: verificationDetails ?? this.verificationDetails,
    );
  }

  static bool isValidStatus(String status) {
    return [
      STATUS_ACTIVE,
      STATUS_COMPLETED,
      STATUS_CANCELLED,
      STATUS_IN_PROGRESS,
      STATUS_PENDING
    ].contains(status);
  }

  static bool isValidPaymentStatus(String status) {
    return [
      PAYMENT_STATUS_PENDING,
      PAYMENT_STATUS_PROCESSING,
      PAYMENT_STATUS_COMPLETED,
      PAYMENT_STATUS_FAILED,
      PAYMENT_STATUS_REFUNDED
    ].contains(status);
  }

  static bool isValidVerificationStatus(String status) {
    return [
      VERIFICATION_STATUS_PENDING,
      VERIFICATION_STATUS_APPROVED,
      VERIFICATION_STATUS_REJECTED
    ].contains(status);
  }

  static bool isValidPrice(double price) {
    return price >= MIN_PRICE && price <= MAX_PRICE;
  }
}
