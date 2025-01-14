import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/database_provider.dart';
import '../widgets/profile_menu_item.dart';
import 'personal_info_screen.dart';
import 'address_screen.dart';
import 'contact_preference_screen.dart';
import 'payment_methods_screen.dart';
import 'notifications_screen.dart';
import 'help_center_screen.dart';
import 'terms_privacy_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<DatabaseProvider>(
        builder: (context, databaseProvider, child) {
          if (databaseProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            );
          }

          final homeowner = databaseProvider.currentHomeowner;
          final profile = databaseProvider.currentProfile;

          if (homeowner == null || profile == null) {
            return const Center(
              child: Text('Failed to load profile. Please try again.'),
            );
          }

          return CustomScrollView(
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
                          profile.name,
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
                        subtitle: homeowner.phone ?? 'Add phone number',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PersonalInfoScreen(),
                            ),
                          );
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Address',
                        subtitle: homeowner.address ?? 'Add address',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddressScreen(),
                            ),
                          );
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PaymentMethodsScreen(),
                            ),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.phone_outlined,
                        title: 'Contact Preference',
                        subtitle:
                            homeowner.preferredContactMethod.toUpperCase(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ContactPreferenceScreen(),
                            ),
                          );
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpCenterScreen(),
                            ),
                          );
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.policy_outlined,
                        title: 'Terms & Privacy Policy',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TermsPrivacyScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      ProfileMenuItem(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        iconColor: Colors.red,
                        titleColor: Colors.red,
                        onTap: () {
                          context
                              .read<AuthProvider>()
                              .signOutAndNavigate(context);
                        },
                      ),
                      const SizedBox(height: 16),
                      ProfileMenuItem(
                        icon: Icons.delete_forever,
                        title: 'Delete Account',
                        iconColor: Colors.red,
                        titleColor: Colors.red,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Account'),
                              content: const Text(
                                'Are you sure you want to delete your account? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    context
                                        .read<AuthProvider>()
                                        .deleteAccount(context);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
