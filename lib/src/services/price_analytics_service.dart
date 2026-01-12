import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:cardamom_analytics/src/models/auction_data.dart';

class MarketInsights {
  final String season; 
  final String status; 
  final String advice; 
  final String signal; 
  final double weeklyMomentum;
  final List<double> recentArrivals;
  final Map<String, double> stats;
  final Map<String, double> fullStats;
  final double volatility; 
  final double thirtyDayChange;
  final double vsLastYear; 
  final double vsFiveYearAvg; 
  final double vsLongTermAvg; 
  final List<String> farmerAdvisories;
  final double normalRangeMin;
  final double normalRangeMax;
  final String spreadLevel;
  final String spreadMessage;
  final int dataYearCount;
  final int dataMonthCount;
  final int totalDataYearCount;
  final double recentNormalRangeMin;
  final double recentNormalRangeMax;
  final double recentMedian;
  final double recentStdDev;
  final double thirtyDayStdDev;
  final String confidenceLevel; // 'low', 'medium', 'high'
  final DateTime? firstDataDate;
  final DateTime? lastDataDate;
  final double weeklyMin;
  final double weeklyMax;
  final double weeklyAvg;
  final double pricePositionInWeeklyRange; // 0.0 to 1.0
  final double weeklyVolatility; // avg daily change for the week
  final int highestPriceYear;
  final int lowestPriceYear;
  final List<MapEntry<String, double>> seasonalAverages; // Last 3 seasons
  final String verdictAction; // Localization key
  final String verdictRisk; // Localization key
  final String verdictExplanation; // Localization key
  final List<MonthlySeasonality> monthlySeasonality;
  final double pctVsNormal;
  final String stabilityMessage;
  final String weeklySummary;
  final List<int> seasonalPeakMonths;

  MarketInsights({
    required this.season,
    required this.status,
    required this.advice,
    required this.signal,
    required this.weeklyMomentum,
    required this.recentArrivals,
    required this.stats,
    required this.fullStats,
    required this.volatility,
    required this.thirtyDayChange,
    required this.vsLastYear,
    required this.vsFiveYearAvg,
    required this.vsLongTermAvg,
    required this.farmerAdvisories,
    required this.normalRangeMin,
    required this.normalRangeMax,
    required this.spreadLevel,
    required this.spreadMessage,
    required this.dataYearCount,
    required this.dataMonthCount,
    required this.totalDataYearCount,
    required this.recentNormalRangeMin,
    required this.recentNormalRangeMax,
    required this.recentMedian,
    required this.recentStdDev,
    required this.thirtyDayStdDev,
    required this.confidenceLevel,
    this.firstDataDate,
    this.lastDataDate,
    required this.weeklyMin,
    required this.weeklyMax,
    required this.weeklyAvg,
    required this.pricePositionInWeeklyRange,
    required this.weeklyVolatility,
    required this.highestPriceYear,
    required this.lowestPriceYear,
    required this.seasonalAverages,
    required this.verdictAction,
    required this.verdictRisk,
    required this.verdictExplanation,
    required this.monthlySeasonality,
    required this.pctVsNormal,
    required this.stabilityMessage,
    required this.weeklySummary,
    required this.seasonalPeakMonths,
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

class MonthlySeasonality {
  final int month;
  final double relativePrice;
  final double volatility;
  final double confidence;
  final int dataPoints;
  final double pctVsNormal;
  final String strength; // 'Strong', 'Weak', 'Neutral'
  final String risk; // 'High', 'Moderate', 'Low'

  MonthlySeasonality({
    required this.month,
    required this.relativePrice,
    required this.volatility,
    required this.confidence,
    required this.dataPoints,
    required this.pctVsNormal,
    required this.strength,
    required this.risk,
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
  List<PricePerformancePoint> getPricePerformance(List<AuctionData> data, {int period = 14, bool useMaxPrice = false}) {
    if (data.length < period) return [];

    // 1. Group by date to handle multiple auctions per day
    Map<String, List<AuctionData>> grouped = {};
    for (var a in data) {
      final key = "${a.date.year}-${a.date.month}-${a.date.day}";
      grouped.putIfAbsent(key, () => []).add(a);
    }

    // 2. Calculate daily metrics and sort
    List<MapEntry<DateTime, double>> daily = grouped.entries.map((e) {
      final parts = e.key.split("-");
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      
      double value;
      if (useMaxPrice) {
        value = e.value.map((a) => a.maxPrice).reduce(max);
      } else {
        // Assume avgPrice if not maxPrice (quantity aggregation handled elsewhere or via specialized call)
        value = e.value.map((a) => a.avgPrice).reduce((a, b) => a + b) / e.value.length;
      }
      
      return MapEntry(dt, value);
    }).toList()..sort((a, b) => a.key.compareTo(b.key));

    List<PricePerformancePoint> points = [];

    // Bollinger Band calculation: 
    // Upper = SMA + (2 * SD)
    // Lower = SMA - (2 * SD)
    for (int i = 0; i < daily.length; i++) {
      if (i < period - 1) {
        // Not enough data for SMA yet, but we want to return the actual point for alignment
        points.add(PricePerformancePoint(
          date: daily[i].key,
          actual: daily[i].value,
          sma: 0,
          upperBand: 0,
          lowerBand: 0,
        ));
        continue;
      }

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

  /// Special helper for aggregating daily quantity (sums totals)
  List<FlSpot> getDailyQuantitySpots(List<AuctionData> data) {
    if (data.isEmpty) return [];
    
    final chronData = List<AuctionData>.from(data)..sort((a, b) => a.date.compareTo(b.date));
    Map<String, double> dailySum = {};
    List<DateTime> dates = [];
    
    for (var a in chronData) {
      final key = "${a.date.year}-${a.date.month}-${a.date.day}";
      if (!dailySum.containsKey(key)) {
        final parts = key.split("-");
        dates.add(DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])));
      }
      dailySum[key] = (dailySum[key] ?? 0.0) + a.quantity;
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < dates.length; i++) {
      final key = "${dates[i].year}-${dates[i].month}-${dates[i].day}";
      spots.add(FlSpot(i.toDouble(), dailySum[key]!));
    }
    return spots;
  }

  /// Returns the season label for a date (e.g., "2025-26" for Oct 2025)
  String getSeasonLabel(DateTime date) {
    int startYear = date.month >= 7 ? date.year : date.year - 1;
    int endYear = startYear + 1;
    return "$startYear-${endYear.toString().substring(2)}";
  }

  /// Identifies Volatility and Risk using the last 30 unique auction days
  Map<String, dynamic> analyzeRisk(List<AuctionData> data) {
    if (data.length < 2) return {'level': 'Unknown', 'message': 'Not enough data'};
    
    // Group by date for volatility check (already sorted descending)
    Map<String, double> dailyMap = {};
    for (var a in data) {
      final key = "${a.date.year}-${a.date.month}-${a.date.day}";
      // Use average price if multiple auctions on same day
      if (!dailyMap.containsKey(key)) {
        final sameDay = data.where((d) => "${d.date.year}-${d.date.month}-${d.date.day}" == key).toList();
        final avg = sameDay.map((e) => e.avgPrice).reduce((a, b) => a + b) / sameDay.length;
        dailyMap[key] = avg;
      }
      if (dailyMap.length >= 30) break; // Only look at last 30 unique auction days
    }
    
    // Newest is at index 0 because dailyMap was built from descending data
    final sortedDailyPrices = dailyMap.values.toList(); 
    
    // Total Change (Variability): (Newest - Oldest) / Oldest * 100
    // Standard percentage change where price increase = positive %
    double netChange = 0.0;
    if (sortedDailyPrices.length >= 2) {
      final newest = sortedDailyPrices.first;
      final oldest = sortedDailyPrices.last;
      netChange = ((newest - oldest) / oldest) * 100;
    }

    List<double> dailyChanges = [];
    // Calculate daily swings (volatility) - use abs for movement speed
    for (int i = 0; i < sortedDailyPrices.length - 1; i++) {
      double change = ((sortedDailyPrices[i] - sortedDailyPrices[i+1]) / sortedDailyPrices[i+1]).abs() * 100;
      dailyChanges.add(change);
    }
    
    double avgDailyChange = dailyChanges.isEmpty 
        ? 0.0 
        : dailyChanges.reduce((a, b) => a + b) / dailyChanges.length;

    // 30-Day Stability (Standard Deviation)
    double thirtyDayStdDev = 0.0;
    if (sortedDailyPrices.length >= 2) {
      double mean = sortedDailyPrices.reduce((a, b) => a + b) / sortedDailyPrices.length;
      double variance = sortedDailyPrices.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / sortedDailyPrices.length;
      thirtyDayStdDev = sqrt(variance);
    }
    
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
      'netChange': netChange,
      'stdDev': thirtyDayStdDev,
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
        fullStats: {},
        volatility: 0.0,
        thirtyDayChange: 0.0,
        vsLastYear: 0.0,
        vsFiveYearAvg: 0.0,
        vsLongTermAvg: 0.0,
        farmerAdvisories: const [],
        normalRangeMin: 0.0,
        normalRangeMax: 0.0,
        spreadLevel: 'stable',
        spreadMessage: 'market_stable_tip',
        dataYearCount: 0,
        dataMonthCount: 0,
        totalDataYearCount: 0,
        recentNormalRangeMin: 0.0,
        recentNormalRangeMax: 0.0,
        recentMedian: 0.0,
        recentStdDev: 0.0,
        thirtyDayStdDev: 0.0,
        confidenceLevel: 'low',
        weeklyMin: 0.0,
        weeklyMax: 0.0,
        weeklyAvg: 0.0,
        pricePositionInWeeklyRange: 0.0,
        weeklyVolatility: 0.0,
        highestPriceYear: 0,
        lowestPriceYear: 0,
        seasonalAverages: const [],
        verdictAction: "wait_for_clear_trend",
        verdictRisk: "risk_low",
        verdictExplanation: "advice_stable",
        monthlySeasonality: const [],
        pctVsNormal: 0.0,
        stabilityMessage: 'steady_week',
        weeklySummary: "0.0%",
        seasonalPeakMonths: const [],
      );
    }

    // Identify 8-month rolling window (approx 240 days)
    final latest = data.first;
    final thresholdDate = latest.date.subtract(const Duration(days: 240));
    
    // Filter for 8-month window
    var seasonalData = data.where((p) => p.date.isAfter(thresholdDate) || p.date.isAtSameMomentAs(thresholdDate)).toList();
    
    // Fallback: If 8-month data is sparse (< 100 records), use last 100 records
    if (seasonalData.length < 100) {
      seasonalData = data.take(100).toList();
    }

    // Calculate baseline stats using current rolling 8-month window
    final stats = calculateDescriptiveStats(seasonalData);
    
    // Calculate full history stats for absolute extremes
    final fullStats = calculateDescriptiveStats(data);

    // Latest data
    final currentPrice = latest.avgPrice;
    stats['current'] = currentPrice;
    final longTermAvg = stats['mean'] ?? 0.0;

    // Trend (Compare current vs 30 day avg)
    final last30 = data.take(30).toList();
    final avg30 = last30.isEmpty
        ? currentPrice
        : last30.fold(0.0, (sum, p) => sum + p.avgPrice) / last30.length;

    // Risk & Market Status Logic (Strict Rules)
    final risk = analyzeRisk(data.take(180).toList());
    final absVariability = (risk['netChange'] as double? ?? 0.0).abs();
    
    String verdictRisk;
    String marketStatus; // Stable / Moderate / Volatile
    if (absVariability <= 10.0) {
      verdictRisk = "risk_low";
      marketStatus = "stable";
    } else if (absVariability <= 18.0) {
      verdictRisk = "risk_moderate";
      marketStatus = "moderate";
    } else {
      verdictRisk = "risk_high";
      marketStatus = "volatile";
    }

    // Action Logic
    String verdictAction;
    String verdictExplanation;
    
    if (currentPrice >= longTermAvg * 1.05 && marketStatus != "volatile") {
      verdictAction = "good_time_to_sell";
      verdictExplanation = "verdict_explanation_sell";
    } else if (marketStatus == "volatile") {
      verdictAction = "be_cautious";
      verdictExplanation = "verdict_explanation_volatile";
    } else {
      verdictAction = "wait_for_clear_trend";
      verdictExplanation = "verdict_explanation_normal";
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

    double volatility = (risk['volatility'] as double?) ?? 0.0;

    // 4. Calculate Rolling Weekly Momentum (Last 7 days vs Previous 7 days)
    final now = latest.date;
    final thisWeekStart = now.subtract(const Duration(days: 6)); 
    final lastWeekEnd = now.subtract(const Duration(days: 7));
    final lastWeekStart = now.subtract(const Duration(days: 13));
    
    final thisWeekPrices = data.where((p) => 
      (p.date.isAfter(thisWeekStart) || p.date.isAtSameMomentAs(thisWeekStart)) && 
      (p.date.isBefore(now) || p.date.isAtSameMomentAs(now))).toList();
    
    final lastWeekPrices = data.where((p) => 
      (p.date.isAfter(lastWeekStart) || p.date.isAtSameMomentAs(lastWeekStart)) && 
      (p.date.isBefore(lastWeekEnd) || p.date.isAtSameMomentAs(lastWeekEnd))).toList();

    double weeklyMomentumValue = 0.0;
    double weeklyMin = currentPrice;
    double weeklyMax = currentPrice;
    double weeklyAvg = currentPrice;
    double pricePosition = 0.5;
    double weeklyVol = 0.0;

    if (thisWeekPrices.isNotEmpty) {
      final prices = thisWeekPrices.map((p) => p.avgPrice).toList();
      weeklyMin = prices.reduce(min);
      weeklyMax = prices.reduce(max);
      weeklyAvg = prices.reduce((a, b) => a + b) / prices.length;
      
      if (weeklyMax > weeklyMin) {
        pricePosition = (currentPrice - weeklyMin) / (weeklyMax - weeklyMin);
      } else {
        pricePosition = 0.5;
      }

      // Weekly Volatility (avg daily change within this week)
      if (thisWeekPrices.length > 1) {
        List<double> changes = [];
        for (int i = 1; i < thisWeekPrices.length; i++) {
          double c = ((thisWeekPrices[i].avgPrice - thisWeekPrices[i - 1].avgPrice) / thisWeekPrices[i - 1].avgPrice).abs() * 100;
          changes.add(c);
        }
        weeklyVol = changes.reduce((a, b) => a + b) / changes.length;
      }
    }

    if (thisWeekPrices.isNotEmpty && lastWeekPrices.isNotEmpty) {
      final lastWeekAvg = lastWeekPrices.map((p) => p.avgPrice).reduce((a, b) => a + b) / lastWeekPrices.length;
      weeklyMomentumValue = ((weeklyAvg - lastWeekAvg) / lastWeekAvg) * 100;
    }

    // 5. Recent Arrivals (last 7 data points)
    final recentArrivals = data.take(7).map((p) => p.quantityArrived ?? p.quantity).toList().reversed.toList();

    // Calculate full seasonality map
    final seasonalityMap = _calculateSeasonality(data);

    // 6. Farmer Advisories logic
    final advisories = <String>[];
    
    // Price relative to 6-month stats
    final sixMonthData = data.take(120).toList();
    if (sixMonthData.isNotEmpty) {
      final prices6m = sixMonthData.map((e) => e.avgPrice).toList();
      final max6m = prices6m.reduce(max);
      final min6m = prices6m.reduce(min);
      
      // Sync with main advisory: Only suggest selling if not in a "Wait" state
      if (currentPrice >= max6m * 0.97 && verdictAction != 'wait_for_clear_trend') { // Changed from signal != 'wait'
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
    
    if (marketStatus == 'improving' && currentPrice < longTermAvg * 1.1) { // Changed from status == 'improving'
      advisories.add('improving_trend_tip');
    }

    // Seasonality Tips (based on data-driven analysis)
    final currentMonthSeasonality = seasonalityMap.firstWhere(
      (s) => s.month == latest.date.month,
      orElse: () => MonthlySeasonality(
        month: latest.date.month,
        relativePrice: 1.0,
        volatility: 0.1,
        confidence: 0.0,
        dataPoints: 0,
        pctVsNormal: 0.0,
        strength: 'Neutral',
        risk: 'Low',
      ),
    );

    if (currentMonthSeasonality.strength == 'Strong') {
      advisories.add('seasonal_high_tip');
    } else if (currentMonthSeasonality.strength == 'Weak') {
      advisories.add('seasonal_low_tip');
    }

    // Proactive: Look ahead to next month
    final nextMonth = (latest.date.month % 12) + 1;
    final nextMonthSeasonality = seasonalityMap.firstWhere(
      (s) => s.month == nextMonth,
      orElse: () => currentMonthSeasonality, // Fallback
    );

    if (nextMonthSeasonality.strength == 'Strong' && currentMonthSeasonality.strength != 'Strong') {
      advisories.add('seasonal_next_high_tip');
    } else if (nextMonthSeasonality.strength == 'Weak' && currentMonthSeasonality.strength != 'Weak') {
      advisories.add('seasonal_next_low_tip');
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

    // Calculate effective months and years for UI baseline context
    final totalDays = (seasonalData.first.date.difference(seasonalData.last.date).inDays).abs();
    final int dataYearCount = (totalDays / 365.25).floor();
    final int dataMonthCount = (totalDays / 30.44).ceil();

    final totalHistoryDays = (data.first.date.difference(data.last.date).inDays).abs();
    final int totalHistoryYears = (totalHistoryDays / 365.25).ceil();

    // Find Years of Extremes
    int highestYear = 0;
    int lowestYear = 0;
    if (data.isNotEmpty) {
      AuctionData maxAuction = data.first;
      AuctionData minAuction = data.first;
      for (var auction in data) {
        if (auction.avgPrice > maxAuction.avgPrice) maxAuction = auction;
        if (auction.avgPrice < minAuction.avgPrice) minAuction = auction;
      }
      highestYear = maxAuction.date.year;
      lowestYear = minAuction.date.year;
    }

    // 7. Calculate Seasonal Averages (Last 3 Seasons)
    Map<String, List<double>> seasonGroups = {};
    for (var auction in data) {
      final label = getSeasonLabel(auction.date);
      seasonGroups.putIfAbsent(label, () => []).add(auction.avgPrice);
    }

    final sortedSeasons = seasonGroups.keys.toList()..sort();
    final last3Seasons = sortedSeasons.length > 3 
        ? sortedSeasons.sublist(sortedSeasons.length - 3) 
        : sortedSeasons;

    final seasonalAverages = last3Seasons.map((label) {
      final prices = seasonGroups[label]!;
      final avg = prices.reduce((a, b) => a + b) / prices.length;
      return MapEntry(label, avg);
    }).toList();

    // New Analytical Fields for Refined UI
    String weeklySummary = (weeklyMomentumValue >= 0 ? "+" : "") + weeklyMomentumValue.toStringAsFixed(1) + "%";
    
    String stabilityMessage = 'steady_week';
    if (weeklyVol > 2.0) {
      stabilityMessage = 'volatile_week';
    } else if (weeklyMomentumValue.abs() < 0.5) {
      stabilityMessage = 'sideways_week';
    }

    // Estimate current trend (30-day SMA as proxy for current trend value)
    final recent30 = data.take(30).toList();
    double currentTrend = currentPrice;
    if (recent30.isNotEmpty) {
      currentTrend = recent30.map((e) => e.avgPrice).reduce((a, b) => a + b) / recent30.length;
    }
    
    double seasonalFactor = currentMonthSeasonality.relativePrice;
    // pctVsNormal = (CurrentPrice / (EstimatedTrend * SeasonalFactor)) - 1
    double pctVsNormal = ((currentPrice / (currentTrend * seasonalFactor)) - 1) * 100;

    // Seasonal Pattern (find all strong months >= 1.05)
    final seasonalPeakMonths = seasonalityMap
        .where((m) => m.strength == 'Strong')
        .map((m) => m.month)
        .toList()
      ..sort();

    return MarketInsights(
      season: getSeasonLabel(latest.date),
      status: marketStatus,
      advice: verdictExplanation,
      signal: verdictAction,
      weeklyMomentum: weeklyMomentumValue,
      recentArrivals: recentArrivals,
      stats: stats,
      fullStats: fullStats,
      volatility: volatility,
      thirtyDayChange: risk['netChange'] ?? 0.0,
      thirtyDayStdDev: risk['stdDev'] ?? 0.0,
      vsLastYear: vsLastYear,
      vsFiveYearAvg: vsFiveYearAvg,
      vsLongTermAvg: vsLongTermAvg,
      farmerAdvisories: advisories,
      normalRangeMin: longTermAvg - (0.5 * (stats['stdDev'] ?? 0.0)),
      normalRangeMax: longTermAvg + (0.5 * (stats['stdDev'] ?? 0.0)),
      spreadLevel: volatility > 2.5 ? 'very_wide' : (volatility > 1.2 ? 'moderate' : 'narrow'),
      spreadMessage: risk['message'] as String,
      dataYearCount: dataYearCount,
      dataMonthCount: dataMonthCount,
      totalDataYearCount: totalHistoryYears,
      recentNormalRangeMin: recentNormalRangeMin,
      recentNormalRangeMax: recentNormalRangeMax,
      recentMedian: recentMedian,
      recentStdDev: recentStdDev,
      confidenceLevel: totalHistoryYears >= 8 ? 'high' : (totalHistoryYears >= 3 ? 'medium' : 'low'),
      firstDataDate: data.last.date,
      lastDataDate: data.first.date,
      weeklyMin: weeklyMin,
      weeklyMax: weeklyMax,
      weeklyAvg: weeklyAvg,
      pricePositionInWeeklyRange: pricePosition,
      weeklyVolatility: weeklyVol,
      highestPriceYear: highestYear,
      lowestPriceYear: lowestYear,
      seasonalAverages: seasonalAverages,
      verdictAction: verdictAction,
      verdictRisk: verdictRisk,
      verdictExplanation: verdictExplanation,
      monthlySeasonality: seasonalityMap,
      pctVsNormal: pctVsNormal,
      stabilityMessage: stabilityMessage,
      weeklySummary: weeklySummary,
      seasonalPeakMonths: seasonalPeakMonths,
    );
  }

  List<MonthlySeasonality> _calculateSeasonality(List<AuctionData> data) {
    if (data.isEmpty) return [];

    // 1. Group by Year-Month to get monthly averages (Resampling)
    Map<String, List<double>> monthlyPricesMap = {}; // Key: "YYYY-MM"
    List<AuctionData> chronData = List.from(data)..sort((a, b) => a.date.compareTo(b.date));
    
    for (var a in chronData) {
      String key = "${a.date.year}-${a.date.month.toString().padLeft(2, '0')}";
      monthlyPricesMap.putIfAbsent(key, () => []).add(a.avgPrice);
    }

    List<String> sortedMonthKeys = monthlyPricesMap.keys.toList()..sort();
    if (sortedMonthKeys.length < 13) return []; // Need at least 13 months for 12-period decomposition

    List<double> monthlyMeansList = sortedMonthKeys.map((k) {
      final prices = monthlyPricesMap[k]!;
      return prices.reduce((a, b) => a + b) / prices.length;
    }).toList();

    // 2. Multiplicative Decomposition Step 1: Trend Estimation (Centered Moving Average)
    // A 2x12 MA: First a 12-period MA, then a 2-period MA applied to that
    List<double?> trend = List.filled(monthlyMeansList.length, null);
    for (int i = 6; i < monthlyMeansList.length - 6; i++) {
       // CMA Calculation:
       double sum12 = 0;
       for (int j = i - 6; j < i + 6; j++) sum12 += monthlyMeansList[j];
       
       double sum12Next = 0;
       for (int j = i - 5; j <= i + 6; j++) sum12Next += monthlyMeansList[j];
       
       trend[i] = (sum12 / 12.0 + sum12Next / 12.0) / 2.0;
    }

    // 3. Step 2: Detrend (Ratio-to-Moving-Average)
    List<double?> seasonalIndices = List.filled(monthlyMeansList.length, null);
    for (int i = 0; i < monthlyMeansList.length; i++) {
      if (trend[i] != null && trend[i]! > 0) {
        seasonalIndices[i] = monthlyMeansList[i] / trend[i]!;
      }
    }

    // 4. Step 3: Aggregate seasonal factors by Month-of-Year
    Map<int, List<double>> factorsByMonth = {};
    for (int i = 0; i < sortedMonthKeys.length; i++) {
      if (seasonalIndices[i] != null) {
        int month = int.parse(sortedMonthKeys[i].split('-')[1]);
        factorsByMonth.putIfAbsent(month, () => []).add(seasonalIndices[i]!);
      }
    }

    Map<int, double> monthlyAverages = {};
    Map<int, double> monthlyStds = {};
    Map<int, int> dataPointsCount = {};

    factorsByMonth.forEach((month, factors) {
      double mean = factors.reduce((a, b) => a + b) / factors.length;
      monthlyAverages[month] = mean;

      double variance = factors.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / factors.length;
      monthlyStds[month] = sqrt(variance);
      dataPointsCount[month] = factors.length;
    });

    // 5. Step 4: Normalize (ensure sum of indices = 12)
    double sumOfAverages = monthlyAverages.values.isEmpty ? 12.0 : monthlyAverages.values.reduce((a, b) => a + b);
    double normalizationFactor = 12.0 / sumOfAverages;

    final maxPoints = dataPointsCount.values.isEmpty ? 1 : dataPointsCount.values.reduce(max);

    // 6. Final result construction
    List<MonthlySeasonality> results = [];
    for (int month = 1; month <= 12; month++) {
      final avg = (monthlyAverages[month] ?? 1.0) * normalizationFactor;
      final std = monthlyStds[month] ?? 0.0;
      final count = dataPointsCount[month] ?? 0;
      final pctEffect = (avg - 1.0) * 100;

      results.add(MonthlySeasonality(
        month: month,
        relativePrice: avg,
        volatility: std,
        confidence: count / maxPoints,
        dataPoints: count,
        pctVsNormal: pctEffect,
        strength: avg > 1.05 ? 'Strong' : (avg < 0.95 ? 'Weak' : 'Neutral'),
        risk: std > 0.15 ? 'High' : (std > 0.08 ? 'Moderate' : 'Low'),
      ));
    }

    return results;
  }
}
