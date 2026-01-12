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

  Future<int> syncNewData({int maxPages = 20, bool forceDeep = false}) async {
    try {
      int totalNewRecords = 0;
      
      // 1. Get existing keys
      final existingKeys = await _dbHelper.getAllAuctionKeys();

      // 2. Fetch Latest Auctions first
      debugPrint("Syncing latest auctions...");
      final latestAuctions = await _apiService.fetchLatestAuctions();
      
      if (latestAuctions.isEmpty) {
        debugPrint("No results from latest auctions page.");
      }

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
      } else if (!forceDeep && latestAuctions.isNotEmpty) {
        // OPTIMIZATION: If we have the latest auctions and NONE of them are new, 
        // we are likely up to date. Stop here unless a deep sync is forced.
        debugPrint("Latest auctions already in database. Skipping archive crawl.");
        await _updateLastSyncTime();
        return 0;
      }

      // 3. Backward Crawl Archives
      for (int page = 1; page <= maxPages; page++) {
        debugPrint("Syncing archive page $page...");
        final List<AuctionData> pageRecords = await _apiService.fetchAuctionsByPage(page);
        
        if (pageRecords.isEmpty) {
          debugPrint("No more records found on archive page $page. Stopping.");
          break;
        }

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

        // If EVERYTHING on this page already exists, we hit the steady state.
        bool allExist = pageRecords.isNotEmpty && newOnThisPage.isEmpty;
        
        if (allExist && !forceDeep) {
           debugPrint("Reached already synced data on page $page. Stopping.");
           break;
        }
        
        // Short delay only if we are continuing to deeper pages
        if (page < maxPages) {
          await Future.delayed(Duration(milliseconds: page < 3 ? 100 : 500));
        }
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

  /// Checks for new data and returns a list of [AuctionData] newer than [lastKnownDate]
  /// or not present in the database.
  Future<List<AuctionData>> checkForNewData(DateTime? lastKnownDate) async {
    try {
      final List<AuctionData> latestPage = await _apiService.fetchAuctionsByPage(1);
      if (latestPage.isEmpty) return [];

      // Get existing keys to avoid double notification
      final existingKeys = await _dbHelper.getAllAuctionKeys();

      // Find records that are either newer than lastKnownDate 
      // OR have the same date but differ in auctioneer and are not in DB.
      final newAuctions = latestPage.where((auction) {
        final key = "${AppDates.db.format(auction.date)}_${auction.auctioneer.toUpperCase()}";
        
        bool isNewer = lastKnownDate == null || auction.date.isAfter(lastKnownDate);
        bool isTodayButNew = lastKnownDate != null && 
                             auction.date.isAtSameMomentAs(lastKnownDate) && 
                             !existingKeys.contains(key);
                             
        return isNewer || isTodayButNew;
      }).toList();

      // Sort chronological so notifications appear in order
      newAuctions.sort((a, b) => a.date.compareTo(b.date));
      
      return newAuctions;
    } catch (e) {
      debugPrint("Check for new data error: $e");
      return [];
    }
  }
}
