import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'provider/auth_provider.dart';
import 'provider/medication_provider.dart';
import 'provider/activity_provider.dart';
import 'provider/caregiver_provider.dart';
import 'navigation/app_router.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => CaregiverProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        onGenerateRoute: AppRouter.generateRoute,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0056D2),
            surface: const Color(0xFFF8FAFC),
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
