import 'package:workmanager/workmanager.dart';
import 'package:cardamom_analytics/src/services/sync_service.dart';
import 'package:cardamom_analytics/src/services/spices_board_service.dart';
import 'package:cardamom_analytics/src/database/database_helper.dart';
import 'package:cardamom_analytics/src/services/notification_service.dart';
import 'package:cardamom_analytics/src/utils/app_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Top-level function required by Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Ensure plugins are initialized for this isolate
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("Background sync task started: $task");
    
    try {
      // 0. Scheduling: Allow sync between 7 AM and 11:30 PM (Auction hours + buffer)
      final now = DateTime.now();
      final currentHour = now.hour;
      
      if (currentHour < 7 || currentHour >= 23) {
        debugPrint("Background sync skipped: Quiet hours (11:30 PM - 7 AM)");
        return true; 
      }

      // 1. Initialize services manually (since we're in a separate isolate)
      final dbHelper = DatabaseHelper();
      final apiService = SpicesBoardService();
      final syncService = SyncService(dbHelper, apiService);
      final notificationService = NotificationService();
      await notificationService.initialize();

      // 2. Check if notifications are enabled
      final enabled = await AppPreferences.areNotificationsEnabled();
      if (!enabled) {
        debugPrint("Notifications are disabled in settings. Skipping.");
        return true;
      }

      // 3. Get last known auction date
      final lastKnownDate = await AppPreferences.getLastAuctionDate();
      debugPrint("Checking for new data since: $lastKnownDate");
      
      // 4. Check for new data
      final newAuctions = await syncService.checkForNewData(lastKnownDate);

      if (newAuctions.isNotEmpty) {
        debugPrint("${newAuctions.length} new auction(s) detected! Syncing and notifying...");
        
        // 5. Perform actual sync so the app data is fresh
        final newRecords = await syncService.syncNewData(maxPages: 2);
        debugPrint("Sync completed in background. New records: $newRecords");
        
        // 6. Trigger notifications for each new auction
        for (var auction in newAuctions) {
          await notificationService.showNewAuctionNotification(
            auctioneer: auction.auctioneer,
            avgPrice: auction.avgPrice,
            maxPrice: auction.maxPrice,
            date: auction.date,
          );
        }

        // 7. Update last known date to the newest one
        final newestAuction = newAuctions.last;
        await AppPreferences.setLastAuctionDate(newestAuction.date);
      } else {
        debugPrint("No new auction data found at this time.");
      }

      return true;
    } catch (e) {
      debugPrint("Background sync task failed: $e");
      return false;
    }
  });
}
