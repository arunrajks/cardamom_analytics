import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cardamom_analytics/src/models/auction_schedule.dart';
import 'package:cardamom_analytics/src/services/auction_schedule_service.dart';
import 'package:cardamom_analytics/src/services/youtube_service.dart';

part 'auction_schedule_provider.g.dart';

@riverpod
AuctionScheduleService auctionScheduleService(AuctionScheduleServiceRef ref) {
  return AuctionScheduleService();
}

@Riverpod(keepAlive: true)
Future<List<AuctionSchedule>> upcomingAuctions(UpcomingAuctionsRef ref) async {
  final service = ref.watch(auctionScheduleServiceProvider);
  return service.fetchUpcomingSchedules();
}

@Riverpod(keepAlive: true)
Future<bool> isAuctionLiveNow(IsAuctionLiveNowRef ref) async {
  // 1. Time check (static)
  if (!YouTubeService.isAuctionActive()) return false;

  // 2. Schedule check (dynamic)
  final service = ref.watch(auctionScheduleServiceProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  // Search for just today's data to be efficient
  final todaySchedules = await service.fetchSchedules(today, today);
  
  return todaySchedules.isNotEmpty;
}
