import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

import 'provider/auth_provider.dart';
import 'provider/medication_provider.dart';
import 'provider/activity_provider.dart';
import 'provider/caregiver_provider.dart';
import 'provider/rappel_provider.dart';
import 'provider/settings_provider.dart';
import 'provider/aine_provider.dart';
import 'provider/appointment_provider.dart';
import 'provider/partage_provider.dart';
import 'navigation/app_router.dart';
import 'services/notification_service.dart';
import 'services/local_alarm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await dotenv.load(fileName: ".env");

  await NotificationService.init();
  await LocalAlarmService.init();

  final settingsProvider = SettingsProvider();
  await settingsProvider.loadSettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => CaregiverProvider()),
        ChangeNotifierProvider(create: (_) => RappelProvider()),
        ChangeNotifierProvider(create: (_) => AineProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => PartageProvider()),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  Timer? _partageRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Refresh partages periodically so aidants see new invitations
    // without having to log out / log back in.
    _partageRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _refreshPartagesIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _partageRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPartagesIfNeeded();
    }
  }

  void _refreshPartagesIfNeeded() {
    try {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated || auth.token == null || auth.token!.isEmpty) {
        return;
      }

      // Only aidants have "demandes reçues" invitations.
      if (auth.isAine) return;

      final partage = context.read<PartageProvider>();
      partage.fetchPartages(auth).then((_) {
        final nb = partage.countDemandesPourProche(auth);
        auth.setNbDemandes(nb);
      });
    } catch (_) {
      // Ignore refresh failures; UI can still pull-to-refresh / reload later.
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/startup',
      onGenerateRoute: AppRouter.generateRoute,

      locale: settings.locale,
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: settings.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: settings.primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: settings.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: settings.primaryColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'Roboto',
      ),

      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(settings.fontSize)),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
