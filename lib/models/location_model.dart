import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.state,
    this.postalCode,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  String get formattedAddress {
    final parts = [
      address,
      city,
      state,
      postalCode,
    ].where((part) => part != null && part.isNotEmpty).toList();

    return parts.join(', ');
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'city': city,
        'state': state,
        'postal_code': postalCode,
      };

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
    );
  }

  LocationModel copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? postalCode,
  }) {
    return LocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}
