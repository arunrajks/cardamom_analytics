// lib/src/providers/price_provider.dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cardamom_analytics/src/models/auction_data.dart';
import 'package:cardamom_analytics/src/services/spices_board_service.dart';
import 'package:cardamom_analytics/src/database/database_helper.dart';
import 'package:cardamom_analytics/src/services/sync_service.dart';
import 'package:cardamom_analytics/src/services/data_seeder_service.dart';
import 'package:cardamom_analytics/src/services/price_analytics_service.dart';

part 'price_provider.g.dart';

enum ChartRange { oneMonth, sixMonths, oneYear, all }

final chartRangeProvider = StateProvider<ChartRange>((ref) => ChartRange.oneMonth);

/// Global trigger to notify all providers that a data sync has occurred.
/// Incrementing this will cause all auction data providers to invalidate/re-fetch.
final syncTriggerProvider = StateProvider<int>((ref) => 0);

@riverpod
DatabaseHelper databaseHelper(Ref ref) {
  return DatabaseHelper();
}

@riverpod
SpicesBoardService spicesBoardService(Ref ref) {
  return SpicesBoardService();
}

@riverpod
SyncService syncService(Ref ref) {
  return SyncService(
    ref.watch(databaseHelperProvider),
    ref.watch(spicesBoardServiceProvider),
  );
}

@riverpod
DataSeederService dataSeederService(Ref ref) {
  return DataSeederService(ref.watch(databaseHelperProvider));
}

@riverpod
PriceAnalyticsService priceAnalyticsService(Ref ref) {
  return PriceAnalyticsService();
}

@riverpod
Future<DateTime?> lastSyncTime(Ref ref) async {
  final sync = ref.watch(syncServiceProvider);
  return sync.getLastSyncTime();
}

@riverpod
Future<List<AuctionData>> historicalFullPrices(Ref ref) async {
  // Watch the trigger: whenever it changes, this provider will re-run
  ref.watch(syncTriggerProvider);
  
  final db = ref.watch(databaseHelperProvider);
  final localData = await db.getByDateRange(); // No range = All data
  
  // Trigger background sync on startup or when this provider is first watched.
  // This ensures the "Latest Auctions" tab is always fresh.
  final sync = ref.read(syncServiceProvider);
  
  // ignore: discarded_futures
  sync.syncNewData(maxPages: 3).then((count) {
    if (count > 0) {
      debugPrint("Startup sync found $count new records. Triggering app-wide refresh.");
      ref.read(syncTriggerProvider.notifier).state++;
    }
    // Always invalidate lastSyncTime to update the UI message
    ref.invalidate(lastSyncTimeProvider);
  }).catchError((e) {
    debugPrint("Startup sync failed: $e");
  });

  return _deduplicate(localData);
}

@riverpod
Future<List<AuctionData>> dailyPrices(Ref ref) async {
  // Watch the trigger
  ref.watch(syncTriggerProvider);
  
  // Offline-first: Fetch from DB immediately
  final db = ref.watch(databaseHelperProvider);
  // Fetch more initially so chart looks good
  final localData = await db.getRecentAuctions(30); 
  
  // Trigger background sync safely without awaiting it to block UI
  final sync = ref.read(syncServiceProvider);
  
  sync.syncNewData().then((count) {
    if (count > 0) {
      // If new data arrived, trigger global refresh
      ref.read(syncTriggerProvider.notifier).state++;
    }
  }).catchError((e) {
    debugPrint("Background sync failed: $e");
  });

  return _deduplicate(localData);
}

@riverpod
Future<List<AuctionData>> historicalPrices(Ref ref, {DateTime? fromDate, DateTime? toDate}) async {
  // Watch the trigger
  ref.watch(syncTriggerProvider);
  
  final db = ref.watch(databaseHelperProvider);
  final localData = await db.getByDateRange(from: fromDate, to: toDate);
  return _deduplicate(localData);
}

/// Helper function to remove duplicate AuctionData entries.
/// This is necessary because of historical case-sensitive data in the DB.
List<AuctionData> _deduplicate(List<AuctionData> data) {
  final seen = <String>{};
  final uniqueData = <AuctionData>[];
  for (final a in data) {
    final key = "${a.date.toIso8601String().split('T')[0]}_${a.auctioneer.toUpperCase().trim()}_${a.avgPrice}_${a.quantity}";
    if (seen.add(key)) {
      uniqueData.add(a);
    }
  }
  return uniqueData;
}
