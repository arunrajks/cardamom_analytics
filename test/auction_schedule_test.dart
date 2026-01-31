import 'package:flutter_test/flutter_test.dart';
import 'package:cardamom_analytics/src/models/auction_schedule.dart';
import 'package:cardamom_analytics/src/services/auction_schedule_service.dart';

void main() {
  group('AuctionSchedule Model', () {
    test('should correctly parse from JSON', () {
      final json = {
        'AUCTIONDATE': '2026-01-27',
        'COMPANY': 'Test Auctioneer',
        'ID': '14',
        'SESSION': 'morning',
        'NUMBER': '31',
      };
      
      final schedule = AuctionSchedule.fromJson(json);

      expect(schedule.auctioneer, 'Test Auctioneer');
      expect(schedule.session, 'morning');
      expect(schedule.centre, 'Puttady');
    });

    test('toJson should return correct map', () {
      final date = DateTime(2026, 1, 27);
      final schedule = AuctionSchedule(
        date: date,
        auctioneer: 'Test Auctioneer',
        centre: 'Puttady',
        session: 'afternoon',
        number: '31',
      );

      final json = schedule.toJson();
      expect(json['auctioneer'], 'Test Auctioneer');
      expect(json['session'], 'afternoon');
      expect(json['date'], date.toIso8601String());
    });
  });

  group('AuctionScheduleService', () {
    test('Service instantiation', () {
       final service = AuctionScheduleService();
       expect(service, isNotNull);
    });

    // We can't easily test network calls without mocking, 
    // but we'll run a smoke test on the real service in a separate step if needed.
  });
}
