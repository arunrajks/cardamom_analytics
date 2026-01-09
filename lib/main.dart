import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/providers/locale_provider.dart';

import 'package:workmanager/workmanager.dart';
import 'package:cardamom_analytics/src/services/notification_service.dart';
import 'package:cardamom_analytics/src/services/background_sync_worker.dart';
import 'package:cardamom_analytics/src/services/data_seeder_service.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/providers/price_provider.dart';
import 'package:cardamom_analytics/src/ui/dashboard_screen.dart';
import 'package:cardamom_analytics/src/ui/analytics_screen.dart';
import 'package:cardamom_analytics/src/ui/historical_data_screen.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Initialize plugins
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Date Formatting for all supported locales
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('ml', null);
  await initializeDateFormatting('ta', null);

  // Initialize Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  // Initialize Workmanager for background sync
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: kDebugMode,
  );

  // Register a periodic task for new auction checks
  Workmanager().registerPeriodicTask(
    "periodic-auction-check",
    "checkNewAuctions",
    frequency: const Duration(minutes: 30),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // Trigger initial data seeding
    ref.read(dataSeederServiceProvider).seedData().then((_) {
       // Force refresh all data providers once seeding is done
       ref.invalidate(dailyPricesProvider);
       ref.invalidate(historicalPricesProvider);
       ref.invalidate(historicalFullPricesProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Cardamom Analytics',
      theme: ThemeConstants.lightTheme,
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ml'), // Malayalam
        Locale('ta'), // Tamil
      ],
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    HistoricalDataScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: l10n.analytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.history,
          ),
        ],
      ),
    );
  }
}
