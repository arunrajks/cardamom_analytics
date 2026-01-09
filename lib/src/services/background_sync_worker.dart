import 'package:workmanager/workmanager.dart';
import 'package:cardamom_analytics/src/services/sync_service.dart';
import 'package:cardamom_analytics/src/services/spices_board_service.dart';
import 'package:cardamom_analytics/src/database/database_helper.dart';
import 'package:cardamom_analytics/src/services/notification_service.dart';
import 'package:cardamom_analytics/src/utils/app_preferences.dart';
import 'package:flutter/foundation.dart';

/// Top-level function required by Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Background sync task started: $task");
    
    try {
      // 0. Smart Scheduling: Only run during specific windows to save battery
      final now = DateTime.now();
      final minutesSinceMidnight = now.hour * 60 + now.minute;
      
      bool isInWindow = false;
      
      // Window 1: 11:30 AM (690m) to 3:00 PM (900m)
      if (minutesSinceMidnight >= 690 && minutesSinceMidnight <= 900) {
        isInWindow = true;
      }
      // Window 2: 4:30 PM (990m) to 6:30 PM (1110m)
      else if (minutesSinceMidnight >= 990 && minutesSinceMidnight <= 1110) {
        isInWindow = true;
      }
      // Window 3: 9:00 PM (1260m) to 9:30 PM (1290m)
      else if (minutesSinceMidnight >= 1260 && minutesSinceMidnight <= 1290) {
        isInWindow = true;
      }

      if (!isInWindow) {
        debugPrint("Background sync skipped: Outside active auction windows ($now)");
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
        debugPrint("Notifications are disabled. Skipping check.");
        return true;
      }

      // 3. Get last known auction date
      final lastKnownDate = await AppPreferences.getLastAuctionDate();
      
      // 4. Check for new data
      final latestAuction = await syncService.checkForNewData(lastKnownDate);

      if (latestAuction != null) {
        debugPrint("New auction data found! Date: ${latestAuction.date}");
        
        // 5. Trigger notification
        await notificationService.showNewAuctionNotification(
          auctioneer: latestAuction.auctioneer,
          price: latestAuction.avgPrice,
          date: latestAuction.date,
        );

        // 6. Update last known date to avoid spamming
        await AppPreferences.setLastAuctionDate(latestAuction.date);
        
        // 7. Optional: Perform a full sync of new data if user wants
        // await syncService.syncNewData(maxPages: 2);
      } else {
        debugPrint("No new auction data found.");
      }

      return true;
    } catch (e) {
      debugPrint("Background sync task failed: $e");
      return false;
    }
  });
}
