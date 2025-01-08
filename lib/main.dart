import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/electrician_provider.dart';
import 'providers/homeowner_provider.dart';
import 'features/common/screens/splash_screen.dart';
import 'features/homeowner/screens/homeowner_main_screen.dart';
import 'features/electrician/screens/electrician_main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ElectricianProvider()),
        ChangeNotifierProvider(create: (_) => HomeownerProvider()),
      ],
      child: MaterialApp(
        title: 'ElectriConnect',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/homeowner/dashboard':
              return MaterialPageRoute(
                builder: (_) => const HomeownerMainScreen(),
              );
            case '/electrician/dashboard':
              return MaterialPageRoute(
                builder: (_) => const ElectricianMainScreen(),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
