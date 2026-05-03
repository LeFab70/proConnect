import 'package:flutter/material.dart';

// Screens
import '../screens/auth/startup_screen.dart';
import '../screens/activities/list_activity_screen.dart';
import '../screens/activities/activity_screen.dart';
import '../screens/aine/list_aine_screen.dart';
import '../screens/appointments/appointment_list_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/add_user_screen.dart';
import '../screens/auth/edit_profile_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/caregiver/list_caregiver.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/medications/medication_list_screen.dart';
import '../screens/rappel/list_rappel_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/about_screen.dart';
import '../screens/settings/notifications_screen.dart';
import '../screens/settings/help_support_screen.dart';
import '../screens/settings/change_password_screen.dart';
import '../screens/partage/partageScreen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/partage/demandes_recues_screen.dart';


class AppRouter {
  static const String aineDetail = '/aine-detail';
  static const String partageAine = '/partage-aine';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // AUTH
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case '/addUser':
        return MaterialPageRoute(builder: (_) => const CreateAdminPage());

      case '/startup':
        return MaterialPageRoute(builder: (_) => const StartupScreen());

      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());

      case '/editprofil':
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      // DASHBOARD
      case '/dashboard':
      case '/dashboardAine':
      case '/dashboardAidant':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      // MODULES
      case '/activities':
        return MaterialPageRoute(builder: (_) => const ListActivityScreen());

      case '/activities_daily':
        return MaterialPageRoute(
          builder: (_) => const ActivitySettingsScreen(),
        );

      case '/appointments':
        return MaterialPageRoute(builder: (_) => const AppointmentListScreen());

      case '/medications':
        return MaterialPageRoute(builder: (_) => const MedicationListScreen());

      case '/rappel':
        return MaterialPageRoute(builder: (_) => const ListRappelScreen());

      case '/caregiver':
        return MaterialPageRoute(builder: (_) => const ListCaregiverScreen());

      case '/aine':
        return MaterialPageRoute(builder: (_) => const ListAineScreen());

      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case '/user':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      // SETTINGS
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case '/settings/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case '/settings/help':
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());

      case '/settings/password':
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      case '/settings/about':
        return MaterialPageRoute(builder: (_) => const AboutScreen());

      // PARTAGE
      case '/partageAine':
        return MaterialPageRoute(
          builder: (_) => PartageScreen(initialData: settings.arguments),
        );

      case '/demandeRecue':
        return MaterialPageRoute(builder: (_) => const DemandesRecuesScreen());

      // DEFAULT
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page non trouvée"))),
        );
    }
  }
}
