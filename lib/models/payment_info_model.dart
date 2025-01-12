class PaymentInfo {
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String routingNumber;
  final String accountType;

  const PaymentInfo({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.routingNumber,
    this.accountType = 'Checking',
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
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'routingNumber': routingNumber,
      'accountType': accountType,
    };
  }

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      accountName: json['accountName'],
      accountNumber: json['accountNumber'],
      bankName: json['bankName'],
      routingNumber: json['routingNumber'],
      accountType: json['accountType'] ?? 'Checking',
    );
  }
}
