class PaymentInfo {
  final String? accountName;
  final String? accountNumber;
  final String? bankName;
  final String? routingNumber;
  final String? accountType;

  const PaymentInfo({
    this.accountName,
    this.accountNumber,
    this.bankName,
    this.routingNumber,
    this.accountType,
  });

  PaymentInfo copyWith({
    String? accountName,
    String? accountNumber,
    String? bankName,
    String? routingNumber,
    String? accountType,
  }) {
    return PaymentInfo(
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      routingNumber: routingNumber ?? this.routingNumber,
      accountType: accountType ?? this.accountType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_name': accountName,
      'bank_name': bankName,
      'account_type': accountType,
      'account_number': accountNumber,
      'routing_number': routingNumber,
    };
  }

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      accountName: json['account_name'],
      bankName: json['bank_name'],
      accountType: json['account_type'],
      accountNumber: json['account_number'],
      routingNumber: json['routing_number'],
    );
  }
}
