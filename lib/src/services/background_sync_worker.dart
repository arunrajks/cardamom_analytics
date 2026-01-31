import 'package:workmanager/workmanager.dart';
import 'package:cardamom_analytics/src/services/sync_service.dart';
import 'package:cardamom_analytics/src/services/spices_board_service.dart';
import 'package:cardamom_analytics/src/database/database_helper.dart';
import 'package:cardamom_analytics/src/services/notification_service.dart';
import 'package:cardamom_analytics/src/utils/app_preferences.dart';
import 'package:flutter/material.dart';

/// Top-level function required by Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    final now = DateTime.now();
    debugPrint("[BackgroundSync] Worker heartbeat at ${now.toIso8601String()} | Task: $task");

    try {
      // 1. Check Schedule Frequency
      final hour = now.hour;
      final minute = now.minute;
      final currentTimeInMinutes = hour * 60 + minute;

      // Define windows in minutes from start of day
      final bool isPeak15 = (currentTimeInMinutes >= (12 * 60 + 30) && currentTimeInMinutes <= (15 * 60)) || // 12:30-15:00
                            (currentTimeInMinutes >= (17 * 60) && currentTimeInMinutes <= (19 * 60));      // 17:00-19:00
      
      final bool isPeak30 = hour >= 11 && hour < 21; // 11 AM to 9 PM

      int requiredIntervalMins = 60; // Default: night
      if (isPeak15) {
        requiredIntervalMins = 15;
      } else if (isPeak30) {
        requiredIntervalMins = 30;
      }
      
      final lastAttempt = await AppPreferences.getLastFetchAttemptTime();
      if (lastAttempt != null) {
        final minutesSinceLastFetch = now.difference(lastAttempt).inMinutes;
        // Subtract a small buffer (e.g., 1 min) because Workmanager scheduling isn't exact
        if (minutesSinceLastFetch < (requiredIntervalMins - 1)) {
          debugPrint("[BackgroundSync] Skipping: Last fetch was $minutesSinceLastFetch mins ago. Required: $requiredIntervalMins mins.");
          return true;
        }
      }

      // Record this attempt
      await AppPreferences.setLastFetchAttemptTime(now);

      // 2. Initialize services
      final dbHelper = DatabaseHelper();
      final apiService = SpicesBoardService();
      final syncService = SyncService(dbHelper, apiService);
      final notificationService = NotificationService();
      
      // Ensure initialization actually completes
      debugPrint("[BackgroundSync] Initializing NotificationService…");
      await notificationService.initialize();

      // 3. Check if notifications enabled
      final enabled = await AppPreferences.areNotificationsEnabled();
      if (!enabled) {
        debugPrint("[BackgroundSync] Skipped: Notifications disabled by user preference.");
        return true;
      }

      // 4. Check & Sync Data
      debugPrint("[BackgroundSync] Checking for new data…");
      final lastKnownDate = await AppPreferences.getLastAuctionDate();
      final newAuctions = await syncService.checkForNewData(lastKnownDate);

      if (newAuctions.isNotEmpty) {
        debugPrint("[BackgroundSync] FOUND ${newAuctions.length} new auctions! Last known date was $lastKnownDate");
        
        // Sync the actual records (limited to 2 pages in background for efficiency)
        await syncService.syncNewData(maxPages: 2);
        
        // Trigger notifications for new findings
        for (var auction in newAuctions) {
          debugPrint("[BackgroundSync] Triggering notification for ${auction.auctioneer}");
          await notificationService.showPriceNotification(
            auctioneer: auction.auctioneer,
            avgPrice: auction.avgPrice,
            maxPrice: auction.maxPrice,
            quantity: auction.quantity,
            date: auction.date,
          );
        }

        // Update last known notified date to the latest auction date found
        final latestDate = newAuctions.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b);
        await AppPreferences.setLastAuctionDate(latestDate);
      } else {
        debugPrint("[BackgroundSync] No new auctions found since $lastKnownDate");
      }

      return true;
    } catch (e, stack) {
      debugPrint("[BackgroundSync] CRITICAL FAILURE: $e");
      debugPrint(stack.toString());
      return false;
    }
  });
}
