import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/medications/medication_list_screen.dart';
import '../screens/medications/add_medication_screen.dart';
import '../screens/activities/activity_screen.dart';
import '../screens/activities/add_activity_screen.dart';
import '../screens/caregiver/caregivers_screen.dart';
import '../screens/caregiver/add_caregiver_screen.dart';
import '../screens/documents/documents_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case '/medications':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MedicationListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
        );

      case '/addMedication':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AddMedicationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutExpo,
                    ),
                  ),
              child: child,
            );
          },
        );

      case '/activities':
        return MaterialPageRoute(builder: (_) => const ActivityScreen());

      case '/addActivity':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AddActivityScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutExpo,
                    ),
                  ),
              child: child,
            );
          },
        );

      case '/caregivers':
        return MaterialPageRoute(builder: (_) => const CaregiversScreen());

      case '/addCaregiver':
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const AddCaregiverScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutExpo,
                    ),
                  ),
              child: child,
            );
          },
        );

      case '/documents':
        return MaterialPageRoute(builder: (_) => const DocumentsScreen());

      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            backgroundColor: Color(0xFFF4F7FC),
            body: Center(
              child: Text(
                "Page introuvable",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ),
        );
    }
  }
}
