import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/services/logger_service.dart';
import '../../../models/service_category_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/homeowner_provider.dart';
import '../../../widgets/primary_button.dart';
import '../widgets/job_status_card.dart';
import '../widgets/recent_electrician_card.dart';
import '../../../providers/notification_provider.dart';
import 'all_electricians_screen.dart';
import 'category_services_screen.dart';

class HomeownerHomeScreen extends StatefulWidget {
  const HomeownerHomeScreen({super.key});

  @override
  State<HomeownerHomeScreen> createState() => _HomeownerHomeScreenState();
}

class _HomeownerHomeScreenState extends State<HomeownerHomeScreen> {
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      // Start listening to notifications
      final notificationProvider = context.read<NotificationProvider>();
      notificationProvider.startListeningToNotifications();
      notificationProvider
          .loadNotifications(); // Load notifications immediately
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh count when returning from notifications screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().refreshUnreadCount();
    });
  }

  @override
  void dispose() {
    // Stop listening to notifications
    context.read<NotificationProvider>().stopListeningToNotifications();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final dbProvider = context.read<DatabaseProvider>();
      await dbProvider.loadCurrentProfile();
      await dbProvider.loadCurrentProfile();

      if (mounted) {
        setState(() {
          _isInitialLoad = false;
        });
      }
    } catch (e) {
      LoggerService.error('Failed to load homeowner data', e);
      if (mounted) {
        setState(() {
          _isInitialLoad = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load data. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildServiceCategory({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '20% Off First Service',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book any service today and get 20% off',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Book Now',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoad) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Consumer<DatabaseProvider>(
                            builder: (context, provider, child) {
                              return Text(
                                provider.currentProfile?.name ?? 'Welcome',
                                style: AppTextStyles.h2,
                              );
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                        icon: Consumer<NotificationProvider>(
                          builder: (context, provider, child) {
                            final unreadCount = provider.unreadCount.when(
                              initial: () => 0,
                              loading: () => 0,
                              error: (_) => 0,
                              success: (count) => count,
                            );
                            return Badge(
                              label: Text(unreadCount.toString()),
                              child: const Icon(Icons.notifications_outlined),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search for services...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Promotion Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildPromotionCard(),
                ),
              ),

              // Services Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Services',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildServiceCategory(
                            title: 'Electrical\nServices',
                            icon: Icons.electrical_services,
                            color: Colors.blue,
                            onTap: () {
                              final category = ServiceCategory.findById(
                                  'electrical_services');
                              if (category != null) {
                                Navigator.pushNamed(
                                  context,
                                  '/category_services',
                                  arguments: category,
                                );
                              }
                            },
                          ),
                          _buildServiceCategory(
                            title: 'Plumbing\nServices',
                            icon: Icons.plumbing,
                            color: Colors.green,
                            onTap: () {
                              final category =
                                  ServiceCategory.findById('plumbing_services');
                              if (category != null) {
                                Navigator.pushNamed(
                                  context,
                                  '/category_services',
                                  arguments: category,
                                );
                              }
                            },
                          ),
                          _buildServiceCategory(
                            title: 'HVAC\nServices',
                            icon: Icons.ac_unit,
                            color: Colors.orange,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('HVAC services coming soon!'),
                                ),
                              );
                            },
                          ),
                          _buildServiceCategory(
                            title: 'Cleaning\nServices',
                            icon: Icons.cleaning_services,
                            color: Colors.purple,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Cleaning services coming soon!'),
                                ),
                              );
                            },
                          ),
                          _buildServiceCategory(
                            title: 'Painting\nServices',
                            icon: Icons.format_paint,
                            color: Colors.red,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Painting services coming soon!'),
                                ),
                              );
                            },
                          ),
                          _buildServiceCategory(
                            title: 'More\nServices',
                            icon: Icons.more_horiz,
                            color: Colors.grey,
                            onTap: () {
                              // TODO: Implement more services screen
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Popular Services
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Popular Services',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildPopularServiceItem(
                              'Emergency Electrical Repair',
                              '24/7 available',
                              Icons.flash_on,
                              Colors.amber,
                            ),
                            const Divider(height: 24),
                            _buildPopularServiceItem(
                              'AC Installation & Repair',
                              'Beat the heat',
                              Icons.ac_unit,
                              Colors.blue,
                            ),
                            const Divider(height: 24),
                            _buildPopularServiceItem(
                              'Deep House Cleaning',
                              'Professional cleaning service',
                              Icons.cleaning_services,
                              Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Padding
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularServiceItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios,
          color: AppColors.textSecondary,
          size: 16,
        ),
      ],
    );
  }
}
