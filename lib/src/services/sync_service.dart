import 'package:shared_preferences/shared_preferences.dart';
import 'package:cardamom_analytics/src/database/database_helper.dart';
import 'package:cardamom_analytics/src/services/spices_board_service.dart';
import 'package:flutter/foundation.dart';
import 'package:cardamom_analytics/src/models/auction_data.dart';
import 'package:cardamom_analytics/src/utils/app_dates.dart';
import 'package:cardamom_analytics/src/utils/app_preferences.dart';

class SyncService {
  final DatabaseHelper _dbHelper;
  final SpicesBoardService _apiService;
  static const String _lastSyncKey = 'last_sync_timestamp';

  SyncService(this._dbHelper, this._apiService);

  Future<int> syncNewData({int maxPages = 20}) async {
    try {
      int totalNewRecords = 0;
      
      // 1. Get all existing auction keys to identify duplicates accurately
      // Key format: "YYYY-MM-DD_AUCTIONEER"
      final existingKeys = await _dbHelper.getAllAuctionKeys();

      // 2. Fetch Latest Auctions first (from main daily-price.html)
      debugPrint("Syncing latest auctions...");
      final latestAuctions = await _apiService.fetchLatestAuctions();
      final newLatest = latestAuctions.where((r) {
        final key = "${AppDates.db.format(r.date)}_${r.auctioneer.toUpperCase()}";
        return !existingKeys.contains(key);
      }).toList();

      if (newLatest.isNotEmpty) {
        await _dbHelper.insertBatch(newLatest);
        totalNewRecords += newLatest.length;
        for (var r in newLatest) {
          existingKeys.add("${AppDates.db.format(r.date)}_${r.auctioneer.toUpperCase()}");
        }
      }

      // 3. Backward Crawl Archives: Start from Page 1 and move backwards
      for (int page = 1; page <= maxPages; page++) {
        debugPrint("Syncing archive page $page...");
        final List<AuctionData> pageRecords = await _apiService.fetchAuctionsByPage(page);
        
        if (pageRecords.isEmpty) {
          debugPrint("No more records found on archive page $page. Stopping.");
          break;
        }

        // Filter for records not in DB using composite key
        final newOnThisPage = pageRecords.where((r) {
          final key = "${AppDates.db.format(r.date)}_${r.auctioneer.toUpperCase()}";
          return !existingKeys.contains(key);
        }).toList();
        
        if (newOnThisPage.isNotEmpty) {
           await _dbHelper.insertBatch(newOnThisPage);
           totalNewRecords += newOnThisPage.length;
           for (var r in newOnThisPage) {
             existingKeys.add("${AppDates.db.format(r.date)}_${r.auctioneer.toUpperCase()}");
           }
        }

        // If we found a page where EVERYTHING is already in the DB, 
        // we likely reached the end of the "gap" or new data.
        bool allExist = pageRecords.every((r) {
          final key = "${AppDates.db.format(r.date)}_${r.auctioneer}";
          return existingKeys.contains(key);
        });
        if (allExist && page > 2) { // Allow some overlap in first few pages
           debugPrint("All records on archive page $page already exist. Stopping sync.");
           break;
        }
        
        await Future.delayed(const Duration(milliseconds: 600));
      }

      await _updateLastSyncTime();

      // Update last known auction date for notifications
      final latestInDb = await _dbHelper.getRecentAuctions(1);
      if (latestInDb.isNotEmpty) {
        final lastNotified = await AppPreferences.getLastAuctionDate();
        if (lastNotified == null || latestInDb.first.date.isAfter(lastNotified)) {
           await AppPreferences.setLastAuctionDate(latestInDb.first.date);
        }
      }

      return totalNewRecords;
    } catch (e) {
      debugPrint("Sync error: $e");
      rethrow;
    }
  }

  Future<void> _updateLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_lastSyncKey);
    if (str != null) {
      return DateTime.parse(str);
    }
    return null;
  }

  /// Checks for new data and returns the latest [AuctionData] if it's newer than [lastKnownDate]
  Future<AuctionData?> checkForNewData(DateTime? lastKnownDate) async {
    try {
      final List<AuctionData> latestPage = await _apiService.fetchAuctionsByPage(1);
      if (latestPage.isEmpty) return null;

      // Sort by date descending (should already be sorted, but to be sure)
      latestPage.sort((a, b) => b.date.compareTo(a.date));
      final latest = latestPage.first;

      if (lastKnownDate == null || latest.date.isAfter(lastKnownDate)) {
        return latest;
      }
      return null;
    } catch (e) {
      debugPrint("Check for new data error: $e");
      return null;
    }
  }
}
