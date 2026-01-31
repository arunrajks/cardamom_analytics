import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:cardamom_analytics/src/models/auction_schedule.dart';
import 'package:flutter/foundation.dart';

class AuctionScheduleService {
  final String _url = 'https://www.indianspices.com/auction_schedule/auction_list.php';

  Future<List<AuctionSchedule>> fetchSchedules(DateTime fromDate, DateTime toDate) async {
    // Try primary format first
    final schedules = await _fetchWithFormat(fromDate, toDate, 'yyyy-MM-dd');
    if (schedules.isNotEmpty) return schedules;
    
    // Fallback to dd-MM-yyyy if first one returns empty
    return _fetchWithFormat(fromDate, toDate, 'dd-MM-yyyy');
  }

  Future<List<AuctionSchedule>> _fetchWithFormat(DateTime fromDate, DateTime toDate, String format) async {
    try {
      final fromStr = DateFormat(format).format(fromDate);
      final toStr = DateFormat(format).format(toDate);

      debugPrint("[Schedule] Fetching JSON with format $format: $fromStr to $toStr");

      final response = await http.post(
        Uri.parse(_url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'X-Requested-With': 'XMLHttpRequest',
          'Accept': 'application/json, text/javascript, */*; q=0.01',
          'Referer': 'https://www.indianspices.com/auction_schedule/',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
        body: {
          'from_date': fromStr,
          'to_date': toStr,
          'company': '',
          'auction_no': '',
          'reg_list': 'Registered Auctioner List',
          'length': '1000',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> data = json['data'] ?? [];
        
        List<AuctionSchedule> schedules = data.map((item) => AuctionSchedule.fromJson(item)).toList();
        
        // Explicitly sort by date to handle potential server-side ordering inconsistencies
        schedules.sort((a, b) => a.date.compareTo(b.date));
        
        debugPrint("[Schedule] Format $format found ${schedules.length} schedules");
        return schedules;
      } else {
        debugPrint("[Schedule] Failed to load ($format): ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("[Schedule] Fetch error ($format): $e");
      return [];
    }
  }

  /// Finds the next available auction date and returns its schedules
  Future<List<AuctionSchedule>> fetchUpcomingSchedules() async {
    final now = DateTime.now();
    // Normalize to start of day for comparison
    DateTime searchStartDate = DateTime(now.year, now.month, now.day);
    
    // Per USER recommendation: After 3 PM, focus on the next day's scheduled auctions
    if (now.hour >= 15) {
      searchStartDate = searchStartDate.add(const Duration(days: 1));
    }
    
    final nextWeek = searchStartDate.add(const Duration(days: 7));
    
    final allSchedules = await fetchSchedules(searchStartDate, nextWeek);
    if (allSchedules.isEmpty) return [];

    // Sort by date to be sure
    allSchedules.sort((a, b) => a.date.compareTo(b.date));

    // Find the first date that has auctions
    // If today has auctions, we might want to show them if they haven't happened yet, 
    // but usually "Upcoming" refers to the next available day.
    // Let's pick the first date in the sorted list.
    final firstAvailableDate = allSchedules.first.date;
    
    return allSchedules.where((s) => 
      s.date.year == firstAvailableDate.year &&
      s.date.month == firstAvailableDate.month &&
      s.date.day == firstAvailableDate.day
    ).toList();
  }
}
