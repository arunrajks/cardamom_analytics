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
    WidgetsFlutterBinding.ensureInitialized();
    final now = DateTime.now();
    debugPrint("[BackgroundSync] Worker heartbeat at ${now.toIso8601String()}");

    try {
      // 1. Check Schedule Frequency
      // 11 AM to 9 PM: 30 mins (proceed every task)
      // Others: 1 hour (proceed every other task if on 30 min timer)
      final hour = now.hour;
      final isPeakTime = hour >= 11 && hour < 21; // 11 AM to 9 PM
      
      final lastAttempt = await AppPreferences.getLastFetchAttemptTime();
      if (lastAttempt != null) {
        final difference = now.difference(lastAttempt);
        if (!isPeakTime && difference.inMinutes < 55) {
          debugPrint("[BackgroundSync] Outside peak hours (11AM-9PM). Skipping fetch as last fetch was ${difference.inMinutes} mins ago.");
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
      await notificationService.initialize();

      // 3. Check if notifications enabled
      final enabled = await AppPreferences.areNotificationsEnabled();
      if (!enabled) {
        debugPrint("[BackgroundSync] Skipped: Notifications disabled.");
        return true;
      }

      // 4. Check & Sync Data
      final lastKnownDate = await AppPreferences.getLastAuctionDate();
      final newAuctions = await syncService.checkForNewData(lastKnownDate);

      if (newAuctions.isNotEmpty) {
        debugPrint("[BackgroundSync] FOUND ${newAuctions.length} new auctions!");
        
        // Sync the actual records
        await syncService.syncNewData(maxPages: 2);
        
        // Trigger notifications for new findings
        for (var auction in newAuctions) {
          await notificationService.showPriceNotification(
            auctioneer: auction.auctioneer,
            avgPrice: auction.avgPrice,
            maxPrice: auction.maxPrice,
            quantity: auction.quantity,
            date: auction.date,
          );
        }

        // Update last known notified date
        await AppPreferences.setLastAuctionDate(newAuctions.last.date);
      } else {
        debugPrint("[BackgroundSync] No new auctions found.");
      }

      return true;
    } catch (e) {
      debugPrint("[BackgroundSync] CRITICAL FAILURE: $e");
      return false;
    }
  });
}
