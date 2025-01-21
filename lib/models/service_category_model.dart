import 'package:flutter/material.dart';
import 'service_model.dart';

enum ServiceProviderType {
  company,
  independent,
}

class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final double baseHourlyRate;
  final int minimumHours;
  final int maxProfessionals;
  final List<String> requiredQualifications;
  final ServiceProviderType providerType;
  final List<Service> services;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.baseHourlyRate,
    required this.minimumHours,
    required this.maxProfessionals,
    required this.requiredQualifications,
    required this.providerType,
    required this.services,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'color': color.value,
      'baseHourlyRate': baseHourlyRate,
      'minimumHours': minimumHours,
      'maxProfessionals': maxProfessionals,
      'requiredQualifications': requiredQualifications,
      'providerType': providerType.name,
      'services': services.map((service) => service.toJson()).toList(),
    };
  }

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: IconData(json['icon'] ?? 0xf1c8, fontFamily: 'MaterialIcons'),
      color: Color(json['color'] ?? 0xFF2196F3),
      baseHourlyRate: (json['baseHourlyRate'] ?? 0.0).toDouble(),
      minimumHours: json['minimumHours'] ?? 1,
      maxProfessionals: json['maxProfessionals'] ?? 1,
      requiredQualifications:
          List<String>.from(json['requiredQualifications'] ?? []),
      providerType: ServiceProviderType.values.firstWhere(
        (type) => type.name == (json['providerType'] ?? 'independent'),
        orElse: () => ServiceProviderType.independent,
      ),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((service) => Service.fromJson(service))
          .toList(),
    );
  }

  ServiceCategory copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    double? baseHourlyRate,
    int? minimumHours,
    int? maxProfessionals,
    List<String>? requiredQualifications,
    ServiceProviderType? providerType,
    List<Service>? services,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      baseHourlyRate: baseHourlyRate ?? this.baseHourlyRate,
      minimumHours: minimumHours ?? this.minimumHours,
      maxProfessionals: maxProfessionals ?? this.maxProfessionals,
      requiredQualifications:
          requiredQualifications ?? this.requiredQualifications,
      providerType: providerType ?? this.providerType,
      services: services ?? this.services,
    );
  }

  // Sample data for testing
  static final List<ServiceCategory> categories = [
    ServiceCategory(
      id: 'electrical_services',
      name: 'Electrical Services',
      description:
          'Professional electrical services for your home or business. Our licensed electricians can handle everything from repairs to installations.',
      icon: Icons.electrical_services,
      color: Colors.blue,
      baseHourlyRate: 85.0,
      minimumHours: 2,
      maxProfessionals: 2,
      requiredQualifications: [
        'Licensed Electrician',
        'Insured',
        'Emergency Response',
        'Residential Experience'
      ],
      providerType: ServiceProviderType.independent,
      services: [
        Service(
          id: 'electrical_repair',
          title: 'Electrical Repair',
          description:
              'Fix electrical issues, replace faulty wiring, and ensure your electrical system is safe and up to code.',
          price: 85.0,
        ),
        Service(
          id: 'electrical_installation',
          title: 'Electrical Installation',
          description:
              'Install new electrical systems, outlets, lighting fixtures, and more.',
          price: 95.0,
        ),
      ],
    ),
    ServiceCategory(
      id: 'plumbing_services',
      name: 'Plumbing Services',
      description:
          'Expert plumbing services for all your needs. From fixing leaks to installing new fixtures, our plumbers are here to help.',
      icon: Icons.plumbing,
      color: Colors.green,
      baseHourlyRate: 75.0,
      minimumHours: 1,
      maxProfessionals: 1,
      requiredQualifications: [
        'Licensed Plumber',
        'Insured',
        'Emergency Response'
      ],
      providerType: ServiceProviderType.company,
      services: [
        Service(
          id: 'leak_repair',
          title: 'Leak Repair',
          description: 'Find and fix leaks in pipes, faucets, and fixtures.',
          price: 75.0,
        ),
        Service(
          id: 'drain_cleaning',
          title: 'Drain Cleaning',
          description: 'Clear clogged drains and ensure proper water flow.',
          price: 85.0,
        ),
      ],
    ),
  ];

  // Helper method to find a category by ID
  static ServiceCategory? findById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
