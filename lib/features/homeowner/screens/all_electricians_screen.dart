import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/electrician_model.dart';
import '../../../providers/database_provider.dart';
import '../widgets/electrician_card.dart';
import 'package:provider/provider.dart';

class AllElectriciansScreen extends StatelessWidget {
  const AllElectriciansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'All Electricians',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Consumer<DatabaseProvider>(
        builder: (context, provider, child) {
          final electricians = provider.electricians;

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (electricians.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No electricians found',
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: electricians.length,
            itemBuilder: (context, index) {
              final electrician = electricians[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElectricianCard(
                  id: electrician.id,
                  name: electrician.profile.name,
                  rating: electrician.rating,
                  specialty: electrician.specialties.isNotEmpty
                      ? electrician.specialties.join(" & ")
                      : 'General Electrician',
                  price: '\$${electrician.hourlyRate.toStringAsFixed(0)}/hr',
                  distance: '2.5 km away', // TODO: Add location calculation
                  availability: electrician.isAvailable
                      ? 'Available Today'
                      : 'Unavailable',
                  isVerified: electrician.isVerified,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
