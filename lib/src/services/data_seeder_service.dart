import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';

import 'package:cardamom_analytics/src/database/database_helper.dart';
import 'package:cardamom_analytics/src/models/auction_data.dart';
import 'package:cardamom_analytics/src/utils/app_dates.dart';

class DataSeederService {
  final DatabaseHelper _dbHelper;

  static const String _seedKey =
      'has_seeded_initial_data_v20_date_only';

  DataSeederService(this._dbHelper);

  Future<int> seedData({bool force = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeeded = prefs.getBool(_seedKey) ?? false;

    if (hasSeeded && !force) {
      debugPrint('[SEEDER] Already seeded. Skipping.');
      return 0;
    }

    try {
      debugPrint('[SEEDER] Loading assets/historical_data.csv via rootBundle.loadString…');
      String csvString = await rootBundle.loadString('assets/historical_data.csv');
      
      debugPrint('[SEEDER] Raw CSV Length: ${csvString.length} characters');
      
      // Diagnostic: Print hex of first 20 chars
      if (csvString.isNotEmpty) {
        String hex = csvString.substring(0, min(20, csvString.length))
            .codeUnits
            .map((u) => u.toRadixString(16).padLeft(2, '0'))
            .join(' ');
        debugPrint('[SEEDER] Start Hex: $hex');
      }

      // Normalization
      if (csvString.contains('\r')) {
        debugPrint('[SEEDER] Normalizing line endings (\r identified)');
        csvString = csvString.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
      }
      csvString = csvString.trim();

      // Diagnostic: Check rows with different EOLs
      final lines = const LineSplitter().convert(csvString);
      debugPrint('[SEEDER] LineSplitter sanity check: ${lines.length} lines identified.');

      // Try Auto-detect first
      List<List<dynamic>> rows = const CsvToListConverter(shouldParseNumbers: false).convert(csvString);
      debugPrint('[SEEDER] Auto-detect parser found ${rows.length} rows.');

      if (rows.length <= 1) {
        debugPrint('[SEEDER] Auto-detect failed (Rows: ${rows.length}). Forcing EOL variants...');
        final rowsN = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(csvString);
        final rowsRN = const CsvToListConverter(eol: '\r\n', shouldParseNumbers: false).convert(csvString);
        final rowsR = const CsvToListConverter(eol: '\r', shouldParseNumbers: false).convert(csvString);
        
        debugPrint('[SEEDER] Try EOL \\n: ${rowsN.length} rows');
        debugPrint('[SEEDER] Try EOL \\r\\n: ${rowsRN.length} rows');
        debugPrint('[SEEDER] Try EOL \\r: ${rowsR.length} rows');

        if (rowsN.length > rows.length) rows = rowsN;
        if (rowsRN.length > rows.length) rows = rowsRN;
        if (rowsR.length > rows.length) rows = rowsR;
      }

      if (rows.length <= 1) {
        if (rows.isNotEmpty) {
          debugPrint('[SEEDER] Row 0 Sample (First 200 chars): ${rows[0].toString().substring(0, min(200, rows[0].toString().length))}');
        }
        throw Exception('CSV parser failed to identify rows. LineSplitter saw ${lines.length} lines, but CSV parser saw ${rows.length}. Check quotes or encoding.');
      }

      final List<AuctionData> records = [];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 7) continue;

        final String rawDate = row[0].toString().trim();

        DateTime? date;
        try {
          date = AppDates.csv.parseStrict(rawDate);
        } catch (e) {
          debugPrint('[SEEDER] Failed to parse date "$rawDate" at row $i: $e');
          continue;
        }

        if (date.year < 2000 || date.year > 2100) continue;

        records.add(
          AuctionData(
            date: date,
            auctioneer: _normalizeAuctioneer(row[1]),
            lots: _parseLots(row[2]),
            quantityArrived: _parseDouble(row[3]),
            quantity: _parseDouble(row[4]),
            maxPrice: _parseDouble(row[5]),
            avgPrice: _parseDouble(row[6]),
          ),
        );
      }

      if (records.isEmpty) {
        throw Exception('No valid records could be parsed from the CSV.');
      }

      await _dbHelper.replaceAll(records);

      await prefs.setBool(_seedKey, true);
      debugPrint('[SEEDER] Seeding completed: ${records.length} records.');
      return records.length;

    } catch (e, stack) {
      debugPrint('[SEEDER] ERROR: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  String _normalizeAuctioneer(dynamic v) {
    return v
        .toString()
        .replaceAll('"', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toUpperCase();
  }

  double _parseDouble(dynamic v) {
    if (v == null) return 0;
    double val;
    if (v is num) {
      val = v.toDouble();
    } else {
      val = double.tryParse(v.toString().replaceAll(',', '')) ?? 0;
    }
    // Round to 2 decimal places
    return (val * 100).round() / 100.0;
  }

  int _parseLots(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.round();
    double val = double.tryParse(v.toString().replaceAll(',', '')) ?? 0;
    return val.round();
  }
}
