import 'dart:math';
import 'package:cardamom_analytics/src/models/auction_data.dart';

class MarketInsights {
  final String season; 
  final String status; 
  final String advice; 
  final String signal; 
  final double weeklyMomentum;
  final List<double> recentArrivals;
  final Map<String, double> stats;
  final double volatility; 
  final double vsLastYear; 
  final double vsFiveYearAvg; 
  final double vsLongTermAvg; 
  final List<String> farmerAdvisories;
  final double normalRangeMin;
  final double normalRangeMax;
  final String spreadLevel;
  final String spreadMessage;
  final int dataYearCount;
  final double recentNormalRangeMin;
  final double recentNormalRangeMax;
  final double recentMedian;

  MarketInsights({
    required this.season,
    required this.status,
    required this.advice,
    required this.signal,
    required this.weeklyMomentum,
    required this.recentArrivals,
    required this.stats,
    required this.volatility,
    required this.vsLastYear,
    required this.vsFiveYearAvg,
    required this.vsLongTermAvg,
    required this.farmerAdvisories,
    required this.normalRangeMin,
    required this.normalRangeMax,
    required this.spreadLevel,
    required this.spreadMessage,
    required this.dataYearCount,
    required this.recentNormalRangeMin,
    required this.recentNormalRangeMax,
    required this.recentMedian,
  });
}

class PricePerformancePoint {
  final DateTime date;
  final double actual;
  final double sma;
  final double upperBand;
  final double lowerBand;

  PricePerformancePoint({
    required this.date,
    required this.actual,
    required this.sma,
    required this.upperBand,
    required this.lowerBand,
  });
}

class PriceAnalyticsService {
  
  /// Calculates descriptive statistics: Mean, Median, Min, Max, StdDev
  Map<String, double> calculateDescriptiveStats(List<AuctionData> data) {
    if (data.isEmpty) return {};
    
    final prices = data.map((e) => e.avgPrice).toList();
    prices.sort();
    
    double sum = prices.reduce((a, b) => a + b);
    double mean = sum / prices.length;
    
    double median;
    int middle = prices.length ~/ 2;
    if (prices.length % 2 == 1) {
      median = prices[middle];
    } else {
      median = (prices[middle - 1] + prices[middle]) / 2.0;
    }
    
    double minPrice = prices.first;
    double maxPrice = prices.last;
    
    // Standard Deviation
    double variance = prices.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / prices.length;
    double stdDev = sqrt(variance);
    
    return {
      'mean': mean,
      'median': median,
      'min': minPrice,
      'max': maxPrice,
      'stdDev': stdDev,
      'range': maxPrice - minPrice,
    };
  }

  /// Calculates Price Performance data (SMA + Volatility Bands)
  /// Uses a 14-day period as recommended for commodity markets.
  List<PricePerformancePoint> getPricePerformance(List<AuctionData> data, {int period = 14}) {
    if (data.length < period) return [];

    // 1. Group by date to handle multiple auctions per day
    Map<String, List<double>> grouped = {};
    for (var a in data) {
      final key = "${a.date.year}-${a.date.month}-${a.date.day}";
      grouped.putIfAbsent(key, () => []).add(a.avgPrice);
    }

    // 2. Calculate daily averages and sort
    List<MapEntry<DateTime, double>> daily = grouped.entries.map((e) {
      final parts = e.key.split("-");
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return MapEntry(dt, e.value.reduce((a, b) => a + b) / e.value.length);
    }).toList()..sort((a, b) => a.key.compareTo(b.key));

    List<PricePerformancePoint> points = [];

    // Bollinger Band calculation: 
    // Upper = SMA + (2 * SD)
    // Lower = SMA - (2 * SD)
    for (int i = period - 1; i < daily.length; i++) {
      final window = daily.sublist(i - (period - 1), i + 1);
      final prices = window.map((e) => e.value).toList();
      
      double sum = prices.reduce((a, b) => a + b);
      double sma = sum / period;

      double variance = prices.map((x) => pow(x - sma, 2)).reduce((a, b) => a + b) / period;
      double stdDev = sqrt(variance);

      points.add(PricePerformancePoint(
        date: daily[i].key,
        actual: daily[i].value,
        sma: sma,
        upperBand: sma + (2 * stdDev),
        lowerBand: sma - (2 * stdDev),
      ));
    }

    return points;
  }

  /// Returns the season label for a date (e.g., "2025-26" for Oct 2025)
  String getSeasonLabel(DateTime date) {
    int startYear = date.month >= 7 ? date.year : date.year - 1;
    int endYear = startYear + 1;
    return "$startYear-${endYear.toString().substring(2)}";
  }

  /// Identifies Volatility and Risk
  Map<String, dynamic> analyzeRisk(List<AuctionData> data) {
    if (data.length < 2) return {'level': 'Unknown', 'message': 'Not enough data'};
    
    // Group by date for volatility check
    Map<String, double> daily = {};
    for (var a in data) {
      final key = "${a.date.year}-${a.date.month}-${a.date.day}";
      daily[key] = (daily[key] ?? 0) + a.avgPrice; // Simplification: just sum
    }
    
    final sortedDailyPrices = daily.values.toList();
    
    List<double> dailyChanges = [];
    for (int i = 1; i < sortedDailyPrices.length; i++) {
      double change = ((sortedDailyPrices[i] - sortedDailyPrices[i-1]) / sortedDailyPrices[i-1]).abs() * 100;
      dailyChanges.add(change);
    }
    
    double avgDailyChange = dailyChanges.isEmpty 
        ? 0.0 
        : dailyChanges.reduce((a, b) => a + b) / dailyChanges.length;
    
    String riskLevel = "Low";
    String riskMessage = "Market is very stable. Good time for slow decisions.";
    
    if (avgDailyChange > 3.0) {
      riskLevel = "High";
      riskMessage = "Prices are swinging wildly. Be very careful with large stock.";
    } else if (avgDailyChange > 1.5) {
      riskLevel = "Moderate";
      riskMessage = "Normal market movements detected. Stay alert.";
    }
    
    return {
      'level': riskLevel,
      'message': riskMessage,
      'volatility': avgDailyChange,
    };
  }

  /// Market Decision Logic (Farmer Friendly)
  MarketInsights getMarketInsights(List<AuctionData> data) {
    if (data.isEmpty) {
      return MarketInsights(
        season: "N/A",
        status: "stable",
        advice: "syncing",
        signal: "wait",
        weeklyMomentum: 0.0,
        recentArrivals: const [],
        stats: {},
        volatility: 0.0,
        vsLastYear: 0.0,
        vsFiveYearAvg: 0.0,
        vsLongTermAvg: 0.0,
        farmerAdvisories: const [],
        normalRangeMin: 0.0,
        normalRangeMax: 0.0,
        spreadLevel: 'stable',
        spreadMessage: 'market_stable_tip',
        dataYearCount: 0,
        recentNormalRangeMin: 0.0,
        recentNormalRangeMax: 0.0,
        recentMedian: 0.0,
      );
    }

    final stats = calculateDescriptiveStats(data);

    // Latest data
    final latest = data.first;
    final currentPrice = latest.avgPrice;
    final longTermAvg = stats['mean'] ?? 0.0;

    // Trend (Compare current vs 30 day avg)
    final last30 = data.take(30).toList();
    final avg30 = last30.isEmpty
        ? currentPrice
        : last30.fold(0.0, (sum, p) => sum + p.avgPrice) / last30.length;

    String status = "stable";
    if (currentPrice > avg30 * 1.05) status = "improving";
    if (currentPrice < avg30 * 0.95) status = "weakening";

    // Signal Logic
    String signal = "hold_signal";
    String advice = "advice_stable";

    if (currentPrice > longTermAvg * 1.15) {
      signal = "sell_now";
      advice = "advice_high";
    } else if (currentPrice < longTermAvg * 0.85) {
      signal = "wait";
      advice = "advice_low";
    } else if (status == "improving") {
      advice = "advice_improving";
    }

    // Comparison Metrics
    double vsLastYear = 0.0;
    final oneYearAgo = latest.date.subtract(const Duration(days: 365));
    final lastYearData = data
        .where((p) =>
            p.date.isBefore(oneYearAgo) &&
            p.date.isAfter(oneYearAgo.subtract(const Duration(days: 30))))
        .toList();
    if (lastYearData.isNotEmpty) {
      double lastYearAvg =
          lastYearData.fold(0.0, (sum, p) => sum + p.avgPrice) /
              lastYearData.length;
      vsLastYear = ((currentPrice - lastYearAvg) / lastYearAvg) * 100;
    }

    double vsFiveYearAvg = 0.0;
    final fiveYearsAgo = latest.date.subtract(const Duration(days: 365 * 5));
    final fiveYearData =
        data.where((p) => p.date.isAfter(fiveYearsAgo)).toList();
    if (fiveYearData.isNotEmpty) {
      double fiveYearAvg =
          fiveYearData.fold(0.0, (sum, p) => sum + p.avgPrice) /
              fiveYearData.length;
      vsFiveYearAvg = ((currentPrice - fiveYearAvg) / fiveYearAvg) * 100;
    }

    double vsLongTermAvg = ((currentPrice - longTermAvg) / longTermAvg) * 100;

    // Risk/Volatility
    final risk = analyzeRisk(data.take(180).toList());
    double volatility = (risk['volatility'] as double?) ?? 0.0;

    // 4. Calculate Weekly Momentum (This Week vs Last Week avg)
    final now = latest.date;
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    
    final thisWeekPrices = data.where((p) => (p.date.isAfter(thisWeekStart) || p.date.isAtSameMomentAs(thisWeekStart)) && p.date.isBefore(now.add(const Duration(days: 1)))).toList();
    final lastWeekPrices = data.where((p) => p.date.isAfter(lastWeekStart) && p.date.isBefore(thisWeekStart)).toList();

    double weeklyMomentumValue = 0.0;
    if (thisWeekPrices.isNotEmpty && lastWeekPrices.isNotEmpty) {
      final thisWeekAvg = thisWeekPrices.map((p) => p.avgPrice).reduce((a, b) => a + b) / thisWeekPrices.length;
      final lastWeekAvg = lastWeekPrices.map((p) => p.avgPrice).reduce((a, b) => a + b) / lastWeekPrices.length;
      weeklyMomentumValue = ((thisWeekAvg - lastWeekAvg) / lastWeekAvg) * 100;
    }

    // 5. Recent Arrivals (last 7 data points)
    final recentArrivals = data.take(7).map((p) => p.quantityArrived ?? p.quantity).toList().reversed.toList();

    // 6. Farmer Advisories logic
    final advisories = <String>[];
    
    // Price relative to 6-month stats
    final sixMonthData = data.take(120).toList();
    if (sixMonthData.isNotEmpty) {
      final prices6m = sixMonthData.map((e) => e.avgPrice).toList();
      final max6m = prices6m.reduce(max);
      final min6m = prices6m.reduce(min);
      
      if (currentPrice >= max6m * 0.97) {
        advisories.add('price_near_high');
      } else if (currentPrice <= min6m * 1.03) {
        advisories.add('price_near_low');
      }
    }

    // Arrival volume pressure
    if (recentArrivals.isNotEmpty) {
      final latestArrival = recentArrivals.last;
      final avgArrival = recentArrivals.reduce((a, b) => a + b) / recentArrivals.length;
      
      if (latestArrival > avgArrival * 1.3) {
        advisories.add('high_arrivals');
      } else if (latestArrival < avgArrival * 0.7) {
        advisories.add('low_arrivals');
      }
    }

    // Stability & Trends
    if (volatility < 1.2) {
      advisories.add('market_stable_tip');
    }
    
    if (status == 'improving' && currentPrice < longTermAvg * 1.1) {
      advisories.add('improving_trend_tip');
    }

    // Calculate recent stats for 3-season comparison (last 3 years)
    final threeYearsAgo = latest.date.subtract(const Duration(days: 365 * 3));
    final recentData = data.where((p) => p.date.isAfter(threeYearsAgo)).toList();
    
    // In case we don't have enough history, fallback to at least 100 records
    final effectiveRecentData = recentData.length < 100 ? data.take(100).toList() : recentData;

    final recentStats = calculateDescriptiveStats(effectiveRecentData);
    final double recentMean = recentStats['mean'] ?? 0.0;
    final double recentStdDev = recentStats['stdDev'] ?? 0.0;
    final double recentMedian = recentStats['median'] ?? 0.0;

    final double recentNormalRangeMin = recentMean - (0.5 * recentStdDev);
    final double recentNormalRangeMax = recentMean + (0.5 * recentStdDev);

    return MarketInsights(
      season: getSeasonLabel(latest.date),
      status: status,
      advice: advice,
      signal: signal,
      weeklyMomentum: weeklyMomentumValue,
      recentArrivals: recentArrivals,
      stats: stats,
      volatility: volatility,
      vsLastYear: vsLastYear,
      vsFiveYearAvg: vsFiveYearAvg,
      vsLongTermAvg: vsLongTermAvg,
      farmerAdvisories: advisories,
      normalRangeMin: longTermAvg - (0.5 * (stats['stdDev'] ?? 0.0)),
      normalRangeMax: longTermAvg + (0.5 * (stats['stdDev'] ?? 0.0)),
      spreadLevel: volatility > 2.5 ? 'very_wide' : (volatility > 1.2 ? 'moderate' : 'narrow'),
      spreadMessage: risk['message'] as String,
      dataYearCount: ((data.first.date.difference(data.last.date).inDays).abs() / 365.25).ceil(),
      recentNormalRangeMin: recentNormalRangeMin,
      recentNormalRangeMax: recentNormalRangeMax,
      recentMedian: recentMedian,
    );
  }
}
