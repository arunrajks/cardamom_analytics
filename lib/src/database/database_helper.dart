import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:cardamom_analytics/src/models/auction_data.dart';
import 'package:cardamom_analytics/src/utils/app_dates.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'cardamom_analytics.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE auction_prices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL
          CHECK (date >= '2000-01-01' AND date <= '2100-12-31'),
        auctioneer TEXT NOT NULL COLLATE NOCASE,
        max_price REAL NOT NULL,
        avg_price REAL NOT NULL,
        quantity REAL NOT NULL,
        arrival_quantity REAL,
        lots INTEGER,
        created_at TEXT NOT NULL,
        UNIQUE(date, auctioneer COLLATE NOCASE)
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_date ON auction_prices(date)');
    await db.execute(
        'CREATE INDEX idx_auctioneer ON auction_prices(auctioneer)');
  }

  Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Add missing columns if they don't exist (e.g., from version 2 or broken 3)
      try {
        await db.execute('ALTER TABLE auction_prices ADD COLUMN arrival_quantity REAL');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE auction_prices ADD COLUMN lots INTEGER');
      } catch (_) {}
    }
  }

  /// 🔥 SAFE FULL REPLACEMENT (used by seeder)
  Future<void> replaceAll(List<AuctionData> auctions) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('auction_prices');

      final batch = txn.batch();
      for (final a in auctions) {
        batch.insert(
          'auction_prices',
          {
            'date': AppDates.db.format(a.date),
            'auctioneer': a.auctioneer,
            'max_price': a.maxPrice,
            'avg_price': a.avgPrice,
            'quantity': a.quantity,
            'arrival_quantity': a.quantityArrived,
            'lots': a.lots,
            'created_at': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// DATE RANGE QUERY
  Future<List<AuctionData>> getByDateRange({DateTime? from, DateTime? to}) async {
    final db = await database;
    String? where;
    List<dynamic>? args;

    if (from != null && to != null) {
      where = 'date BETWEEN ? AND ?';
      args = [AppDates.db.format(from), AppDates.db.format(to)];
    } else if (from != null) {
      where = 'date >= ?';
      args = [AppDates.db.format(from)];
    } else if (to != null) {
      where = 'date <= ?';
      args = [AppDates.db.format(to)];
    }

    final maps = await db.query(
      'auction_prices',
      where: where,
      whereArgs: args,
      orderBy: 'date DESC',
    );

    return maps.map(_mapToAuction).toList();
  }

  Future<void> insertBatch(List<AuctionData> auctions) async {
    final db = await database;
    final batch = db.batch();
    for (final a in auctions) {
      batch.insert(
        'auction_prices',
        {
          'date': AppDates.db.format(a.date),
          'auctioneer': a.auctioneer,
          'max_price': a.maxPrice,
          'avg_price': a.avgPrice,
          'quantity': a.quantity,
          'arrival_quantity': a.quantityArrived,
          'lots': a.lots,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<DateTime?> getLatestDate() async {
    final db = await database;
    final result = await db.query(
      'auction_prices',
      orderBy: 'date DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      final String dateStr = result.first['date'] as String;
      return DateTime.parse(dateStr.contains('T') ? dateStr : '${dateStr}T00:00:00');
    }
    return null;
  }

  Future<List<AuctionData>> getRecentAuctions(int limit) async {
    final db = await database;
    final maps = await db.query(
      'auction_prices',
      orderBy: 'date DESC',
      limit: limit,
    );
    return maps.map(_mapToAuction).toList();
  }

  Future<Set<String>> getAllAuctionKeys() async {
    final db = await database;
    final maps = await db.query('auction_prices', columns: ['date', 'auctioneer']);
    return maps.map((m) {
      final date = m['date'] as String;
      final auctioneer = m['auctioneer'] as String;
      return "${date}_$auctioneer";
    }).toSet();
  }

  Future<List<DateTime>> getAllAuctionDates() async {
    final db = await database;
    final maps = await db.query('auction_prices', columns: ['date']);
    return maps.map((m) {
      final String dateStr = m['date'] as String;
      return DateTime.parse(dateStr.contains('T') ? dateStr : '${dateStr}T00:00:00');
    }).toList();
  }

  AuctionData _mapToAuction(Map<String, dynamic> m) {
    final String dateStr = m['date'] as String;
    return AuctionData(
      date: DateTime.parse(dateStr.contains('T') ? dateStr : '${dateStr}T00:00:00'),
      auctioneer: m['auctioneer'],
      maxPrice: m['max_price'],
      avgPrice: m['avg_price'],
      quantity: m['quantity'],
      quantityArrived: m['arrival_quantity'],
      lots: m['lots'],
    );
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.delete('auction_prices');
  }
}
