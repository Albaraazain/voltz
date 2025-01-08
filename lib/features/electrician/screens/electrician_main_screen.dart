import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import 'dashboard_screen.dart';
import 'job_requests_screen.dart';
import 'schedule_screen.dart';
import 'electrician_profile_screen.dart';

class ElectricianMainScreen extends StatefulWidget {
  const ElectricianMainScreen({super.key});

  @override
  State<ElectricianMainScreen> createState() => _ElectricianMainScreenState();
}

class _ElectricianMainScreenState extends State<ElectricianMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const JobRequestsScreen(),
    const ScheduleScreen(),
    const ElectricianProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.primary,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}