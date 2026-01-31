import 'package:intl/intl.dart';

class AuctionSchedule {
  final DateTime date;
  final String auctioneer;
  final String centre;
  final String session; // "Morning" or "Afternoon"
  final String? number;

  AuctionSchedule({
    required this.date,
    required this.auctioneer,
    required this.centre,
    required this.session,
    this.number,
  });

  factory AuctionSchedule.fromJson(Map<String, dynamic> json) {
    // Handle potential date format issues
    DateTime date;
    final dateStr = json['AUCTIONDATE'] ?? '';
    try {
      date = DateTime.parse(dateStr);
    } catch (_) {
      try {
        date = DateFormat('dd-MM-yyyy').parse(dateStr);
      } catch (_) {
        date = DateTime.now(); // Fallback
      }
    }

    // ID mapping: 14 = Puttady, 24 = Bodi, else use ID as string
    String centre = 'Unknown';
    final id = json['ID']?.toString() ?? '';
    if (id == '14') {
      centre = 'Puttady';
    } else if (id == '24') {
      centre = 'Bodinaykanur';
    } else {
      centre = id;
    }

    return AuctionSchedule(
      date: date,
      auctioneer: json['COMPANY'] ?? 'Unknown Auctioneer',
      centre: centre,
      session: json['SESSION'] ?? 'Unknown',
      number: json['NUMBER']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'auctioneer': auctioneer,
      'centre': centre,
      'session': session,
      'number': number,
    };
  }
}
