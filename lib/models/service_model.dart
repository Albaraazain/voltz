class Service {
  final String title;
  final String description;
  final double price;

  const Service({
    required this.title,
    required this.description,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
    };
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
    );
  }
}
