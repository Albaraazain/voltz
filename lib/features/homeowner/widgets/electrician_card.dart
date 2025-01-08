import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class ElectricianCard extends StatelessWidget {
  final String name;
  final String rating;
  final String distance;
  final VoidCallback onTap;

  const ElectricianCard({
    super.key,
    required this.name,
    required this.rating,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(name),
        subtitle: Text('Rating: $rating • $distance away'),
        onTap: onTap,
      ),
    );
  }
}
