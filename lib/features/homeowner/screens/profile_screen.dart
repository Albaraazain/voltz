import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.accent,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'John Doe',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Profile Menu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    onTap: () {
                      // TODO: Navigate to personal info
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Addresses',
                    onTap: () {
                      // TODO: Navigate to addresses
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    onTap: () {
                      // TODO: Navigate to payment methods
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Preferences',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // TODO: Navigate to notifications
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () {
                      // TODO: Navigate to language settings
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Support',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    onTap: () {
                      // TODO: Navigate to help center
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.policy_outlined,
                    title: 'Terms & Privacy Policy',
                    onTap: () {
                      // TODO: Navigate to terms
                    },
                  ),
                  const SizedBox(height: 32),
                  ProfileMenuItem(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    iconColor: Colors.red,
                    titleColor: Colors.red,
                    onTap: () {
                      context.read<AuthProvider>().signOutAndNavigate(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
