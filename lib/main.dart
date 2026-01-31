import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/providers/locale_provider.dart';

import 'package:workmanager/workmanager.dart';
import 'package:cardamom_analytics/src/services/notification_service.dart';
import 'package:cardamom_analytics/src/services/background_sync_worker.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/providers/price_provider.dart';
import 'package:cardamom_analytics/src/ui/dashboard_screen.dart';
import 'package:cardamom_analytics/src/ui/analytics_screen.dart';
import 'package:cardamom_analytics/src/ui/historical_data_screen.dart';
import 'package:cardamom_analytics/src/ui/live_pulse_screen.dart';
import 'package:cardamom_analytics/src/providers/navigation_provider.dart';
import 'package:cardamom_analytics/src/services/data_seeder_service.dart';

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
  );

  // Register a periodic task for new auction checks
  Workmanager().registerPeriodicTask(
    "periodic-auction-check",
    "checkNewAuctions",
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    initialDelay: const Duration(minutes: 5),
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

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(navigationProvider);
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    AnalyticsScreen(),
    LivePulseScreen(),
    HistoricalDataScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentIndex = ref.watch(navigationProvider);

    // Sync PageController with navigationProvider
    ref.listen<int>(navigationProvider, (previous, next) {
      if (next != _pageController.page?.round()) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          ref.read(navigationProvider.notifier).state = index;
        },
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navigationProvider.notifier).state = index;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: l10n.analytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.videocam_outlined),
            selectedIcon: const Icon(Icons.videocam),
            label: l10n.live,
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
