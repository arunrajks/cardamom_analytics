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
      // 0. Logging: Track entry
      final now = DateTime.now();
      debugPrint("[BackgroundSync] Worker heartbeat at ${now.toIso8601String()}");

      // 1. Initialize services manually
      final dbHelper = DatabaseHelper();
      final apiService = SpicesBoardService();
      final syncService = SyncService(dbHelper, apiService);
      final notificationService = NotificationService();
      await notificationService.initialize();

      // 2. Check settings
      final enabled = await AppPreferences.areNotificationsEnabled();
      if (!enabled) {
        debugPrint("[BackgroundSync] Skipped: Notifications disabled in app settings.");
        return true;
      }

      // 3. Get last known auction date
      final lastKnownDate = await AppPreferences.getLastAuctionDate();
      debugPrint("[BackgroundSync] Searching for new auctions since: ${lastKnownDate ?? 'Beginning'}");
      
      // 4. Check for new data
      final newAuctions = await syncService.checkForNewData(lastKnownDate);

      if (newAuctions.isNotEmpty) {
        debugPrint("[BackgroundSync] FOUND ${newAuctions.length} new auctions! Proceeding with sync...");
        
        // 5. Perform actual sync
        final newRecords = await syncService.syncNewData(maxPages: 2);
        debugPrint("[BackgroundSync] Sync complete. Added $newRecords records to database.");
        
        // 6. Trigger notifications
        for (var auction in newAuctions) {
          debugPrint("[BackgroundSync] Triggering notification for ${auction.auctioneer} (${auction.date})");
          await notificationService.showNewAuctionNotification(
            auctioneer: auction.auctioneer,
            avgPrice: auction.avgPrice,
            maxPrice: auction.maxPrice,
            date: auction.date,
          );
        }

        // 7. Update last known date
        final newestAuction = newAuctions.last;
        await AppPreferences.setLastAuctionDate(newestAuction.date);
        debugPrint("[BackgroundSync] Success: Last auction date updated to ${newestAuction.date}");
      } else {
        debugPrint("[BackgroundSync] No new auctions found yet. Checking again in next cycle.");
      }

      return true;
    } catch (e) {
      debugPrint("[BackgroundSync] CRITICAL FAILURE: $e");
      return false;
    }
  });
}
