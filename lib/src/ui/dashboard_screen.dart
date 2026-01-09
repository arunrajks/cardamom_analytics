import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cardamom_analytics/src/models/auction_data.dart';
import 'package:cardamom_analytics/src/providers/price_provider.dart';
import 'package:cardamom_analytics/src/services/price_analytics_service.dart';
import 'package:cardamom_analytics/src/ui/widgets/app_info_dialog.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/ui/profile_screen.dart';
import 'package:cardamom_analytics/src/providers/locale_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFullPrices = ref.watch(historicalFullPricesProvider);
    final analytics = ref.watch(priceAnalyticsServiceProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ThemeConstants.creamApp,
      body: asyncFullPrices.when(
        data: (prices) {
          if (prices.isEmpty) {
            return _buildEmptyState(context, ref);
          }

          final insights = analytics.getMarketInsights(prices);

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(historicalFullPricesProvider),
            child: CustomScrollView(
              slivers: [
                _buildAppBar(context, l10n, ref),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildPriceOverview(context, prices, insights, l10n),
                        const SizedBox(height: 24),
                        _buildTrendSection(context, ref, prices, l10n),
                        const SizedBox(height: 24),
                        _buildPricePerformanceSection(context, prices, analytics, l10n),
                        const SizedBox(height: 16),
                        _buildWeeklyMomentum(context, insights, l10n),
                        const SizedBox(height: 24),
                        _buildWeeklyRangeIndicator(context, prices, l10n),
                        const SizedBox(height: 24),
                        _buildWeeklyAuctionSummary(context, prices, l10n),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n, WidgetRef ref) {
    return SliverAppBar(
      floating: true,
      backgroundColor: ThemeConstants.creamApp,
      elevation: 0,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => _showAboutDialog(context),
            child: Image.asset(
              'assets/logo.png',
              height: 32,
              width: 32,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showAboutDialog(context),
            child: Text(
              l10n.appTitle,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: ThemeConstants.forestGreen,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.language, color: ThemeConstants.forestGreen),
          onPressed: () => _showLanguageSelector(context, ref),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
          child: const Padding(
            padding: EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: ThemeConstants.forestGreen,
              child: Icon(Icons.person_outline, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AppInfoDialog(),
    );
  }

  void _showLanguageSelector(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectLanguage,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildLangOption(context, ref, 'en', 'English', currentLocale.languageCode == 'en'),
              _buildLangOption(context, ref, 'ml', 'മലയാളം', currentLocale.languageCode == 'ml'),
              _buildLangOption(context, ref, 'ta', 'தமிழ்', currentLocale.languageCode == 'ta'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangOption(BuildContext context, WidgetRef ref, String code, String label, bool isSelected) {
    return ListTile(
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(Locale(code));
        Navigator.pop(context);
      },
      leading: Icon(
        isSelected ? Icons.check_circle : Icons.circle_outlined,
        color: isSelected ? ThemeConstants.forestGreen : Colors.grey[400],
      ),
      title: Text(
        label,
        style: GoogleFonts.outfit(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey[700],
        ),
      ),
      trailing: isSelected ? const Icon(Icons.stars, color: Colors.orange, size: 16) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: ThemeConstants.forestGreen),
            const SizedBox(height: 16),
            Text(l10n.loadingData, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(l10n.preparingRecords, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(dataSeederServiceProvider).seedData(force: true).then((_) {
                  ref.invalidate(dailyPricesProvider);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.forestGreen,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.forceReseedButton),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPriceOverview(BuildContext context, List<AuctionData> prices, MarketInsights insights, AppLocalizations l10n) {
    if (prices.isEmpty) return const SizedBox.shrink();

    final latestDate = prices.first.date;
    final latestAuctions = prices.where((p) =>
        p.date.year == latestDate.year &&
        p.date.month == latestDate.month &&
        p.date.day == latestDate.day).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.latestAuctions,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.forestGreen,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: ThemeConstants.forestGreen),
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.syncing),
                    duration: const Duration(seconds: 2),
                  ),
                );
                
                final ref = ProviderScope.containerOf(context);
                await ref.read(syncServiceProvider).syncNewData(maxPages: 5);
                ref.invalidate(historicalFullPricesProvider);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.updated),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              tooltip: l10n.syncNow,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              Text(
                DateFormat('EEEE, MMM d, yyyy', l10n.locale.languageCode).format(latestDate),
                style: GoogleFonts.outfit(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ...latestAuctions.map((auction) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () => _showAuctionDetails(context, auction, l10n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConstants.paleGreen.withValues(alpha: 0.5),
                        foregroundColor: ThemeConstants.forestGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auction.auctioneer,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  l10n.translate('Tap for details'),
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹ ${NumberFormat("#,##0").format(auction.avgPrice)}',
                            style: GoogleFonts.outfit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.info_outline, size: 16),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  void _showAuctionDetails(BuildContext context, AuctionData auction, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Text(
              auction.auctioneer,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd-MMM-yyyy').format(auction.date),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(l10n.translate('No. of Lots'), auction.lots?.toString() ?? 'N/A'),
            _buildDetailRow(l10n.translate('Total Qty Arrived'), '${auction.quantityArrived ?? 0} ${l10n.kg}'),
            _buildDetailRow(l10n.qtySold, '${auction.quantity} ${l10n.kg}'),
            const Divider(height: 24),
            _buildDetailRow(l10n.max, '₹ ${NumberFormat("#,##0").format(auction.maxPrice)}'),
            _buildDetailRow(l10n.avgPrice, '₹ ${NumberFormat("#,##0").format(auction.avgPrice)}', isBold: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('Close'), style: const TextStyle(color: ThemeConstants.forestGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? ThemeConstants.forestGreen : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTrendSection(BuildContext context, WidgetRef ref, List<AuctionData> prices, AppLocalizations l10n) {
    final range = ref.watch(chartRangeProvider);
    
    // Filter history based on range
    DateTime cutoff;
    final now = DateTime.now();
    switch (range) {
      case ChartRange.oneMonth:
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case ChartRange.sixMonths:
        cutoff = now.subtract(const Duration(days: 180));
        break;
      case ChartRange.oneYear:
        cutoff = now.subtract(const Duration(days: 365));
        break;
      case ChartRange.all:
        cutoff = DateTime(2000);
        break;
    }

    final history = prices.where((p) => p.date.isAfter(cutoff)).toList().reversed.toList();
    
    if (history.isEmpty) {
      return Center(child: Text(l10n.translate("no_data_range")));
    }

    // Grouping by date for daily averages
    Map<String, List<double>> groupedByDate = {};
    for (var auction in history) {
      String dateKey = DateFormat('yyyy-MM-dd', l10n.locale.languageCode).format(auction.date);
      groupedByDate.putIfAbsent(dateKey, () => []).add(auction.avgPrice);
    }

    List<MapEntry<DateTime, double>> dailyAverages = groupedByDate.entries.map((e) {
      return MapEntry(
        DateTime.parse(e.key),
        e.value.reduce((a, b) => a + b) / e.value.length,
      );
    }).toList()..sort((a, b) => a.key.compareTo(b.key));

    // Mapping x-axis to time
    final firstTimestamp = dailyAverages.first.key.millisecondsSinceEpoch.toDouble();
    List<FlSpot> spots = [];
    for (var daily in dailyAverages) {
      final x = (daily.key.millisecondsSinceEpoch.toDouble() - firstTimestamp) / (1000 * 60 * 60 * 24);
      spots.add(FlSpot(x, daily.value));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.priceTrend,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen),
            ),
            Row(
              children: [
                _buildToggle(ref, '1M', range == ChartRange.oneMonth, ChartRange.oneMonth),
                _buildToggle(ref, '6M', range == ChartRange.sixMonths, ChartRange.sixMonths),
                _buildToggle(ref, '1Y', range == ChartRange.oneYear, ChartRange.oneYear),
                _buildToggle(ref, 'All', range == ChartRange.all, ChartRange.all),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 250,
          padding: const EdgeInsets.only(top: 24, right: 24, bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 500,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withValues(alpha: 0.1),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: _getBottomInterval(range),
                    getTitlesWidget: (val, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        (val * 1000 * 60 * 60 * 24 + firstTimestamp).toInt(),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _getBottomTitle(date, range, l10n.locale.languageCode),
                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) => Text(
                      '₹${val.toInt()}',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    reservedSize: 45,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: ThemeConstants.forestGreen,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        ThemeConstants.forestGreen.withValues(alpha: 0.2),
                        ThemeConstants.forestGreen.withValues(alpha: 0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _getBottomInterval(ChartRange range) {
    switch (range) {
      case ChartRange.oneMonth: return 7; // Weekly
      case ChartRange.sixMonths: return 30; // Monthly
      case ChartRange.oneYear: return 60; // Every 2 months
      case ChartRange.all: return 365; // Yearly
    }
  }

  String _getBottomTitle(DateTime date, ChartRange range, String locale) {
    if (range == ChartRange.oneMonth) return DateFormat('d MMM', locale).format(date);
    if (range == ChartRange.all) return date.year.toString();
    return DateFormat('MMM', locale).format(date);
  }

  Widget _buildToggle(WidgetRef ref, String label, bool active, ChartRange range) {
    return GestureDetector(
      onTap: () => ref.read(chartRangeProvider.notifier).state = range,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? ThemeConstants.forestGreen : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.grey,
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPricePerformanceSection(BuildContext context, List<AuctionData> prices, PriceAnalyticsService analytics, AppLocalizations l10n) {
    final performance = analytics.getPricePerformance(prices);
    if (performance.isEmpty) return const SizedBox.shrink();

    // Take last 30 points for visibility
    final displayPoints = performance.length > 30 
        ? performance.sublist(performance.length - 30) 
        : performance;

    final firstTimestamp = displayPoints.first.date.millisecondsSinceEpoch.toDouble();
    
    List<FlSpot> actualSpots = [];
    List<FlSpot> smaSpots = [];
    List<FlSpot> upperSpots = [];
    List<FlSpot> lowerSpots = [];

    for (var p in displayPoints) {
      final x = (p.date.millisecondsSinceEpoch.toDouble() - firstTimestamp) / (1000 * 60 * 60 * 24);
      actualSpots.add(FlSpot(x, p.actual));
      smaSpots.add(FlSpot(x, p.sma));
      upperSpots.add(FlSpot(x, p.upperBand));
      lowerSpots.add(FlSpot(x, p.lowerBand));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.trending_up, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.pricePerformance,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.translate('sma_volatility_label'),
          style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                // Legend
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     _buildLegendItem(ThemeConstants.accentGold, l10n.translate('trend_14day')),
                     const SizedBox(width: 12),
                     _buildLegendItem(const Color(0xFF26A69A), l10n.translate('actual_price')),
                     const SizedBox(width: 12),
                     _buildLegendItem(const Color(0xFF26A69A).withValues(alpha: 0.1), l10n.translate('volatility_band')),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 250,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 200,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withValues(alpha: 0.05),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 7,
                            getTitlesWidget: (val, meta) {
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                (val * 1000 * 60 * 60 * 24 + firstTimestamp).toInt(),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('d MMM', l10n.locale.languageCode).format(date),
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 9),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) => Text(
                              '₹${val.toInt()}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 9),
                            ),
                            reservedSize: 40,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (spot) => const Color(0xFF1E222D),
                          fitInsideHorizontally: true,
                          fitInsideVertically: true,
                          getTooltipItems: (touchedSpots) {
                            return touchedSpots.map((spot) {
                              if (spot.barIndex == 2) { // Actual
                                return LineTooltipItem(
                                  '${l10n.translate('actual_label')}: ₹${spot.y.toStringAsFixed(0)}',
                                  const TextStyle(color: Color(0xFF26A69A), fontWeight: FontWeight.bold, fontSize: 11),
                                );
                              }
                              if (spot.barIndex == 3) { // SMA
                                return LineTooltipItem(
                                  '${l10n.translate('sma_14_label')}: ₹${spot.y.toStringAsFixed(0)}',
                                  const TextStyle(color: ThemeConstants.accentGold, fontWeight: FontWeight.bold, fontSize: 11),
                                );
                              }
                              return null;
                            }).toList().whereType<LineTooltipItem>().toList();
                          },
                        ),
                      ),
                      lineBarsData: [
                        // VOLATILITY BAND (UPPER)
                        LineChartBarData(
                          spots: upperSpots,
                          isCurved: true,
                          color: Colors.transparent,
                          barWidth: 0,
                          dotData: const FlDotData(show: false),
                        ),
                        // VOLATILITY BAND (LOWER)
                        LineChartBarData(
                          spots: lowerSpots,
                          isCurved: true,
                          color: Colors.transparent,
                          barWidth: 0,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF26A69A).withValues(alpha: 0.1),
                          ),
                        ),
                        // ACTUAL PRICE
                        LineChartBarData(
                          spots: actualSpots,
                          isCurved: true,
                          color: const Color(0xFF26A69A),
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                        // SMA
                        LineChartBarData(
                          spots: smaSpots,
                          isCurved: true,
                          color: ThemeConstants.accentGold,
                          barWidth: 2,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                      betweenBarsData: [
                        BetweenBarsData(
                          fromIndex: 0, // Upper
                          toIndex: 1,   // Lower
                          color: const Color(0xFF26A69A).withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoFooter(l10n.translate('moving_average_label'), l10n.translate('moving_average_desc')),
                    const SizedBox(width: 16),
                    _buildInfoFooter(l10n.translate('volatility_bands_label'), l10n.translate('volatility_bands_desc')),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildInfoFooter(String title, String desc) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: ThemeConstants.forestGreen, fontSize: 9, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 9, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildWeeklyMomentum(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    bool isPositive = insights.weeklyMomentum >= 0;
    return GestureDetector(
      onTap: () => _showExplanationDialog(
        context, 
        l10n.momentumExplanation, 
        l10n.momentumDesc
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isPositive ? Colors.green : Colors.red).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.weeklyMomentum,
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Text(
                        '${isPositive ? '+' : ''}${insights.weeklyMomentum.toStringAsFixed(1)}%',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.vsLastWeek,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.info_outline, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyRangeIndicator(BuildContext context, List<AuctionData> prices, AppLocalizations l10n) {
    if (prices.isEmpty) return const SizedBox.shrink();
    
    // Look at last 7 days of data
    final last7Days = prices.take(30).where((p) => 
      p.date.isAfter(DateTime.now().subtract(const Duration(days: 7)))
    ).toList();
    
    final dataPool = last7Days.isEmpty ? prices.take(30).toList() : last7Days;

    final minP = dataPool.map((p) => p.avgPrice).reduce(min);
    final maxP = dataPool.map((p) => p.avgPrice).reduce(max);
    final avgP = prices.first.avgPrice; // Today's average relative to the week's range
    
    // Calculate position % (0 to 1)
    double position = 0.5;
    if (maxP != minP) {
      position = (avgP - minP) / (maxP - minP);
    }

    return GestureDetector(
      onTap: () => _showExplanationDialog(
        context, 
        l10n.rangeExplanation, 
        l10n.rangeDesc
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.weeklyRange,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen),
              ),
              const Icon(Icons.info_outline, color: Colors.grey, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     _buildRangeStat(l10n.min, minP, Colors.grey),
                     _buildRangeStat(l10n.avgPrice, avgP, ThemeConstants.forestGreen),
                     _buildRangeStat(l10n.max, maxP, Colors.grey),
                  ],
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: position.clamp(0.01, 1.0),
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [ThemeConstants.primaryGreen.withValues(alpha: 0.5), ThemeConstants.primaryGreen],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (MediaQuery.of(context).size.width - 88) * position.clamp(0.0, 1.0) - 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: ThemeConstants.primaryGreen, width: 3),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeStat(String label, double value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          '₹${NumberFormat("#,###").format(value)}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
        ),
      ],
    );
  }

  Widget _buildWeeklyAuctionSummary(BuildContext context, List<AuctionData> prices, AppLocalizations l10n) {
    if (prices.isEmpty) return const SizedBox.shrink();

    // Grouping by day and taking last 7 days with data
    final Map<String, List<AuctionData>> grouped = {};
    for (var p in prices) {
      final key = DateFormat('yyyy-MM-dd').format(p.date);
      if (!grouped.containsKey(key)) grouped[key] = [];
      grouped[key]!.add(p);
      if (grouped.length >= 7 && !grouped.containsKey(key)) break;
    }
    
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final displayKeys = sortedKeys.take(7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.weeklyAuctions,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayKeys.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1), indent: 20, endIndent: 20),
            itemBuilder: (context, index) {
              final key = displayKeys.elementAt(index);
              final dayAuctions = grouped[key]!;
              // "Last entry" in the day (latest chronologically)
              final lastAuction = dayAuctions.first; 
              final date = lastAuction.date;

              return ListTile(
                onTap: () => _showDayAuctionsDetail(context, date, dayAuctions, l10n),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: ThemeConstants.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat('dd', l10n.locale.languageCode).format(date), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ThemeConstants.forestGreen)),
                      Text(DateFormat('MMM', l10n.locale.languageCode).format(date).toUpperCase(), style: const TextStyle(fontSize: 9, color: ThemeConstants.forestGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                title: Text(
                  DateFormat('EEEE', l10n.locale.languageCode).format(date),
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  lastAuction.auctioneer,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${NumberFormat("#,###").format(lastAuction.avgPrice.toInt())}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDayAuctionsDetail(BuildContext context, DateTime date, List<AuctionData> auctions, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Column(
          children: [
            Text(DateFormat('dd MMMM yyyy', l10n.locale.languageCode).format(date), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen)),
            Text(DateFormat('EEEE', l10n.locale.languageCode).format(date), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: auctions.length,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            itemBuilder: (context, index) {
              final auction = auctions[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                     decoration: BoxDecoration(
                       color: ThemeConstants.primaryGreen.withValues(alpha: 0.1),
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: Text(
                       auction.auctioneer,
                       style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen, fontSize: 12),
                     ),
                   ),
                   const SizedBox(height: 16),
                   _buildPopupDetailRow(l10n.avgPrice, '₹${NumberFormat("#,###").format(auction.avgPrice.toInt())}', ThemeConstants.forestGreen),
                   const SizedBox(height: 12),
                   _buildPopupDetailRow(l10n.totalQtyLabel, '${NumberFormat("#,###").format((auction.quantityArrived ?? 0.0).toInt())} Kg', Colors.black87),
                   const SizedBox(height: 12),
                   _buildPopupDetailRow(l10n.qtySoldLabel, '${NumberFormat("#,###").format(auction.quantity.toInt())} Kg', Colors.black87),
                   const SizedBox(height: 12),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       _buildSmallStat(l10n.min, '₹${NumberFormat("#,###").format(auction.avgPrice.toInt())}'),
                       _buildSmallStat(l10n.max, '₹${NumberFormat("#,###").format(auction.maxPrice.toInt())}'),
                     ],
                   ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: ThemeConstants.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupDetailRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
      ],
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  void _showExplanationDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: ThemeConstants.forestGreen),
            const SizedBox(width: 12),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen)),
          ],
        ),
        content: Text(message, style: GoogleFonts.outfit(fontSize: 16, height: 1.5, color: Colors.blueGrey.shade800)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: ThemeConstants.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
