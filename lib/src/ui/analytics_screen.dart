import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardamom_analytics/src/providers/price_provider.dart';
import 'package:cardamom_analytics/src/ui/theme/theme_constants.dart';
import 'package:cardamom_analytics/src/services/price_analytics_service.dart';
import 'package:cardamom_analytics/src/localization/app_localizations.dart';
import 'package:cardamom_analytics/src/utils/app_dates.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:cardamom_analytics/src/models/auction_data.dart';

enum ChartRange { oneMonth, sixMonths, oneYear, fiveYears }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _showAllInsights = false;
  ChartRange _chartRange = ChartRange.oneMonth;

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(historicalFullPricesProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ThemeConstants.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.analytics,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: ThemeConstants.textDark),
        ),
        backgroundColor: ThemeConstants.creamApp,
        elevation: 0,
        iconTheme: const IconThemeData(color: ThemeConstants.primaryGreen),
      ),
      body: asyncData.when(
        data: (data) {
          if (data.isEmpty) return Center(child: Text(l10n.noDataInsights));
          
          final analytics = ref.read(priceAnalyticsServiceProvider);
          final insights = analytics.getMarketInsights(data);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSmartAdvisoryCard(context, insights, l10n),
                const SizedBox(height: 32),
                _buildWeeklySnapshotSlider(context, insights, l10n),
                const SizedBox(height: 32),
                _buildMarketPulseSection(context, insights, l10n),
                const SizedBox(height: 32),
                _buildPricePerformanceSection(context, ref, data, l10n, analytics),
                const SizedBox(height: 32),
                _buildKeyStatisticsSection(context, insights, l10n),
                const SizedBox(height: 32),
                _buildResearchHub(context, insights, l10n),
                const SizedBox(height: 32),
                _buildDisclaimer(l10n, insights),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${l10n.translate('error_loading_analytics')}: $err')),
      ),
    );
  }


  Widget _buildWeeklySnapshotSlider(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('weekly_market_snapshot'),
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.textDark),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildSnapshotSliderItem(
                context,
                l10n.translate('weekly_range'),
                "₹${NumberFormat("#,##0").format(insights.weeklyMin)} - ₹${NumberFormat("#,##0").format(insights.weeklyMax)}",
                "${l10n.translate('avg_price_label')}: ₹${NumberFormat("#,##0").format(insights.weeklyAvg)}",
                Icons.unfold_more,
                const Color(0xFFE3F2FD),
                Colors.blue[700]!,
                l10n.translate('weekly_range_help'),
                l10n,
              ),
              _buildSnapshotSliderItem(
                context,
                l10n.translate('weekly_momentum'),
                "${insights.weeklyChangeRupee >= 0 ? "+" : "-"}₹${insights.weeklyChangeRupee.abs().toStringAsFixed(0)}",
                l10n.translate(insights.weeklyChangeRupee >= 0 ? 'up_from_last_week' : 'down_from_last_week'),
                insights.weeklyChangeRupee >= 0 ? Icons.trending_up : Icons.trending_down,
                insights.weeklyChangeRupee >= 0 ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                insights.weeklyChangeRupee >= 0 ? Colors.green[700]! : Colors.red[700]!,
                l10n.translate('weekly_momentum_help'),
                l10n,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMarketPulseSection(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_outlined, color: Color(0xFF8D6E63), size: 24),
            const SizedBox(width: 12),
            Text(
              l10n.translate('decision_summary'),
              style: GoogleFonts.outfit(
                color: const Color(0xFF5D4037),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Premium Integrated Status Row (3 columns)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          ),
          child: Row(
            children: [
              _buildPulseInfoItem(
                context, 
                l10n.actionLabel, 
                l10n.translate(insights.verdictAction),
                insights.verdictAction.contains('sell') ? Colors.green : (insights.verdictAction.contains('wait') ? ThemeConstants.actionOrange : Colors.blue),
                Icons.lightbulb_outline,
              ),
              Container(width: 1, height: 32, color: const Color(0xFFEEEEEE), margin: const EdgeInsets.symmetric(horizontal: 8)),
              _buildPulseInfoItem(
                context, 
                l10n.risk, 
                l10n.translate(insights.verdictRisk),
                insights.verdictRisk.contains('low') ? Colors.green : (insights.verdictRisk.contains('high') ? Colors.red : Colors.orange),
                Icons.security_outlined,
              ),
              Container(width: 1, height: 32, color: const Color(0xFFEEEEEE), margin: const EdgeInsets.symmetric(horizontal: 8)),
              _buildPulseInfoItem(
                context, 
                l10n.translate('status'), 
                l10n.translate(insights.statusBadge),
                insights.statusBadge == 'market_strong' ? Colors.green : (insights.statusBadge == 'market_weakened' ? Colors.red : ThemeConstants.actionOrange),
                Icons.shield_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Deep Market Signals (Deduplicated)
        _buildMarketSignalCards(context, insights, l10n),
      ],
    );
  }

  Widget _buildSnapshotSliderItem(BuildContext context, String title, String value, String subtitle, IconData icon, Color bgColor, Color iconColor, String helpDesc, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _showHelpDialog(context, title, helpDesc, l10n),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: iconColor, size: 16),
                    const SizedBox(width: 8),
                    Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.help_outline, size: 12, color: Colors.grey),
              ],
            ),
            const Spacer(),
            Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.textDark)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, String title, String description, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(description, style: const TextStyle(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('close'), style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConstants.primaryGreen)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartAdvisoryCard(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    String headlineText = _formatAdvisoryText(insights.headlineAdvisory, insights, l10n);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeConstants.primaryGreen,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeConstants.primaryGreen.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.smartAdvisory,
                  style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusPill(context, insights, l10n),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            headlineText,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.advisorySupportLine,
            style: GoogleFonts.outfit(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMetaInfo(Icons.calendar_month, "${l10n.currentSeason}: ${l10n.translate(insights.season)}"),
              const Spacer(),
              _buildMetaInfo(Icons.trending_up, l10n.translate(insights.status).toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAdvisoryText(String key, MarketInsights insights, AppLocalizations l10n) {
    String text = l10n.translate(key);
    if (key.contains('seasonal') && insights.lastDataDate != null) {
      final monthDate = key.contains('next')
          ? DateTime(insights.lastDataDate!.year, insights.lastDataDate!.month + 1)
          : insights.lastDataDate!;
      final monthName = DateFormat('MMMM', l10n.locale.languageCode).format(monthDate);
      text = text.replaceAll('{month}', monthName);
    }
    return text;
  }

  Widget _buildStatusPill(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    Color pillColor;
    switch (insights.verdictAction) {
      case 'good_time_to_sell': pillColor = Colors.greenAccent; break;
      case 'be_cautious': pillColor = ThemeConstants.actionOrange; break;
      default: pillColor = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.translate(insights.verdictAction),
        style: TextStyle(color: pillColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildPricePerformanceSection(BuildContext context, WidgetRef ref, List<AuctionData> prices, AppLocalizations l10n, PriceAnalyticsService analytics) {
    if (prices.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pricePerformance,
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.textDark),
                ),
                Text(
                  l10n.chartExplanationSentence,
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            _buildChartLegend(l10n),
          ],
        ),
        const SizedBox(height: 16),
        _buildRangeSelector(l10n),
        const SizedBox(height: 12),
        Container(
          height: 310, // Increased height for selector and bands
          padding: const EdgeInsets.only(top: 20, right: 10, left: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              Expanded(child: _buildEnhancedMainChart(prices, l10n, analytics)),
              _buildChartFooter(l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRangeSelector(AppLocalizations l10n) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4), // Minor left/right gap
      child: Row(
        children: [
          _buildRangeChip(ChartRange.oneMonth, l10n.translate('range_1m')),
          const SizedBox(width: 8),
          _buildRangeChip(ChartRange.sixMonths, l10n.translate('range_6m')),
          const SizedBox(width: 8),
          _buildRangeChip(ChartRange.oneYear, l10n.translate('range_1y')),
          const SizedBox(width: 8),
          _buildRangeChip(ChartRange.fiveYears, l10n.translate('range_all')),
          const SizedBox(width: 16), // Extra trailing space for better scroll feel
        ],
      ),
    );
  }

  Widget _buildRangeChip(ChartRange range, String label) {
    final isSelected = _chartRange == range;
    return GestureDetector(
      onTap: () => setState(() => _chartRange = range),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ThemeConstants.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? ThemeConstants.primaryGreen : Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChartFooter(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("14D SMA", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(
                  l10n.translate('moving_average_desc'),
                  style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey, height: 1.2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("2σ Bands", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(
                  l10n.translate('volatility_bands_desc'),
                  style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey, height: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(AppLocalizations l10n) {
    return Row(
      children: [
        _buildLegendItem(const Color(0xFFFFA726), "14D SMA"),
        const SizedBox(width: 10),
        _buildLegendItem(const Color(0xFF00695C), "Actual"),
        const SizedBox(width: 10),
        _buildLegendItem(const Color(0xFFB2EBF2), "2σ Bands"),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildEnhancedMainChart(List<AuctionData> data, AppLocalizations l10n, PriceAnalyticsService analytics) {
    // 1. Determine time slice and aggregation
    List<AuctionData> rawSlice = [];
    int aggregationDays = 1;

    switch (_chartRange) {
      case ChartRange.oneMonth:
        // 30 days + 14 day buffer + extra for holidays/weekends
        // 180 raw entries should safely cover enough unique days with 2 sessions/day
        rawSlice = data.take(180).toList().reversed.toList();
        aggregationDays = 1;
        break;
      case ChartRange.sixMonths:
        // 26 weeks + 14 week buffer = 40 weeks. ~280 data points.
        rawSlice = data.take(400).toList().reversed.toList();
        aggregationDays = 7; // Weekly
        break;
      case ChartRange.oneYear:
        // 52 weeks + 14 week buffer = 66 weeks. ~462 data points.
        rawSlice = data.take(700).toList().reversed.toList();
        aggregationDays = 7; // Weekly
        break;
      case ChartRange.fiveYears:
        // 60 months + 14 month buffer = 74 months. ~2220 data points.
        // Or simply take all available data for the most accurate long-term trend
        rawSlice = data.toList().reversed.toList();
        aggregationDays = 30; // Monthly
        break;
    }

    // 2. Aggregate if necessary
    List<AuctionData> aggregated;
    if (aggregationDays > 1) {
      aggregated = _aggregateData(rawSlice, aggregationDays);
    } else {
      aggregated = rawSlice;
    }

    // 3. Calculate Bollinger Bands on the series
    final allAnalysis = analytics.getPricePerformance(aggregated);
    
    // Slice to the actual viewing window
    int displayCount = 30;
    if (_chartRange == ChartRange.sixMonths) displayCount = 26;
    if (_chartRange == ChartRange.oneYear) displayCount = 52;
    if (_chartRange == ChartRange.fiveYears) displayCount = 60;
    
    final points = allAnalysis.length > displayCount 
        ? allAnalysis.sublist(allAnalysis.length - displayCount) 
        : allAnalysis;
    
    if (points.isEmpty) return const SizedBox.shrink();

    final List<FlSpot> actualSpots = [];
    final List<FlSpot> smaSpots = [];
    final List<FlSpot> upperSpots = [];
    final List<FlSpot> lowerSpots = [];
    
    for (int i = 0; i < points.length; i++) {
       actualSpots.add(FlSpot(i.toDouble(), points[i].actual));
       if (points[i].sma > 0) smaSpots.add(FlSpot(i.toDouble(), points[i].sma));
       if (points[i].upperBand > 0) upperSpots.add(FlSpot(i.toDouble(), points[i].upperBand));
       if (points[i].lowerBand > 0) lowerSpots.add(FlSpot(i.toDouble(), points[i].lowerBand));
    }

    // Determine Y axis range ensuring BOTH bands are visible
    // Filter out 0/null values
    final allValues = points.expand((p) => [p.actual, p.upperBand, p.lowerBand]).where((v) => v > 0).toList();
    if (allValues.isEmpty) return const SizedBox.shrink();

    final double minP = allValues.reduce((a, b) => a < b ? a : b);
    final double maxP = allValues.reduce((a, b) => a > b ? a : b);
    final double range = maxP - minP;
    
    // Add 15% padding to each side to ensure extremes of bands aren't clipped
    final double minY = (minP - (range * 0.15)).floorToDouble();
    final double maxY = (maxP + (range * 0.15)).ceilToDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.05), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (_chartRange == ChartRange.oneMonth) ? 7 : (_chartRange == ChartRange.sixMonths ? 4 : 8),
              getTitlesWidget: (value, meta) {
                if (value.toInt() < 0 || value.toInt() >= points.length) return const SizedBox.shrink();
                
                // Show dates at reasonable intervals
                bool shouldShow = false;
                if (_chartRange == ChartRange.oneMonth) {
                  shouldShow = value.toInt() % 7 == 0 || value.toInt() == points.length - 1;
                } else if (_chartRange == ChartRange.sixMonths || _chartRange == ChartRange.oneYear) {
                  shouldShow = value.toInt() % 8 == 0 || value.toInt() == points.length - 1;
                } else {
                   shouldShow = value.toInt() % 12 == 0 || value.toInt() == points.length - 1;
                }

                if (!shouldShow) return const SizedBox.shrink();

                String format = 'd MMM';
                if (_chartRange == ChartRange.fiveYears) format = 'MMM yy';
                if (_chartRange == ChartRange.oneYear) format = 'MMM';

                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat(format, l10n.locale.languageCode).format(points[value.toInt()].date),
                    style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == minY || value == maxY) return const SizedBox.shrink();
                            return Text(
                              '₹${NumberFormat("#,###").format(value.round())}',
                              style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => ThemeConstants.forestGreen.withValues(alpha: 0.9),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index < 0 || index >= points.length) return null;
                            final date = points[index].date;
                            
                            String label = "Actual: ";
                            if (spot.barIndex == 0) label = "Upper: ";
                            if (spot.barIndex == 1) label = "Lower: ";
                            if (spot.barIndex == 2) label = "SMA: ";
                            if (spot.barIndex == 3) label = "Actual: ";

                            // Only show date for the first item in tooltip
                            final dateHeader = touchedSpots.indexOf(spot) == 0 
                                ? "${DateFormat('d MMM yyyy', l10n.locale.languageCode).format(date)}\n" 
                                : "";

                            return LineTooltipItem(
                              "$dateHeader$label",
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                              children: [
                                TextSpan(
                                  text: "₹${NumberFormat("#,##0").format(spot.y.round())}",
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          }).toList();
                        },
                      ),
                    ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: points.length.toDouble() - 1,
        minY: minY,
        maxY: maxY,
        betweenBarsData: [
          BetweenBarsData(
            fromIndex: 0, // Upper Band
            toIndex: 1,   // Lower Band
            color: const Color(0xFFB2EBF2).withValues(alpha: 0.35),
          ),
        ],
        lineBarsData: [
          // Upper Band Line
          LineChartBarData(
            spots: upperSpots,
            isCurved: true,
            color: const Color(0xFFB2EBF2).withValues(alpha: 0.3),
            dashArray: [5, 5],
            barWidth: 1,
            dotData: const FlDotData(show: false),
          ),
          // Lower Band Line
          LineChartBarData(
            spots: lowerSpots,
            isCurved: true,
            color: const Color(0xFFB2EBF2).withValues(alpha: 0.3),
            dashArray: [5, 5],
            barWidth: 1,
            dotData: const FlDotData(show: false),
          ),
          // SMA Line
          LineChartBarData(
            spots: smaSpots,
            isCurved: true,
            color: const Color(0xFFFFA726),
            barWidth: 2,
            dotData: const FlDotData(show: false),
          ),
          // Actual Price Line
          LineChartBarData(
            spots: actualSpots,
            isCurved: true,
            color: const Color(0xFF00695C),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildResearchHub(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    // 1. Market Arrivals Logic
    final recentQty = insights.recentArrivals.isNotEmpty ? insights.recentArrivals.last : 0.0;
    final avgQty = insights.recentArrivals.isNotEmpty 
        ? insights.recentArrivals.reduce((a, b) => a + b) / insights.recentArrivals.length 
        : 0.0;
    final arrivalStatus = recentQty > avgQty * 1.1 
        ? l10n.translate('high_arrivals_status') 
        : (recentQty < avgQty * 0.9 ? l10n.translate('low_arrivals_status') : l10n.translate('stable_supply'));
    final arrivalColor = recentQty > avgQty * 1.1 ? Colors.orange : Colors.green;

    // 2. Export Demand Logic (Heuristic)
    final exportStatus = insights.weeklyMomentum > 1.5 
        ? l10n.translate('strong_demand') 
        : (insights.weeklyMomentum < -1.5 ? l10n.translate('weak_demand') : l10n.translate('strong_demand'));
    final exportColor = insights.weeklyMomentum > 1.5 ? Colors.green : Colors.blue;

    // 3. Seasonal Trends Logic
    final currentMonth = DateTime.now().month;
    final currentSeasonality = insights.monthlySeasonality.firstWhere((m) => m.month == currentMonth, orElse: () => insights.monthlySeasonality.first);
    final seasonalStatus = l10n.translate(currentSeasonality.strength == 'Peak' ? 'peak_month' : 'off_month');

    // 4. Market Stability Logic
    final stabilityStatus = insights.weeklyVolatility > 2.5 
        ? l10n.translate('volatile') 
        : (insights.weeklyVolatility > 1.2 ? l10n.translate('moderate') : l10n.translate('stable'));
    final stabilityColor = insights.weeklyVolatility > 2.5 ? Colors.red : (insights.weeklyVolatility > 1.2 ? Colors.orange : Colors.purple);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('research_hub'),
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: ThemeConstants.textDark,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            _buildResearchCard(
              context,
              l10n.translate('arrivals_insight'),
              arrivalStatus,
              Icons.inventory_2_outlined,
              const Color(0xFFE8F5E9),
              arrivalColor,
              l10n.translate('arrivals_desc'),
              l10n.translate('arrivals_help_text'),
            ),
            _buildResearchCard(
              context,
              l10n.translate('export_demand'),
              exportStatus,
              Icons.public_outlined,
              const Color(0xFFE3F2FD),
              exportColor,
              l10n.translate('export_desc'),
              l10n.translate('demand_help_text'),
            ),
            _buildResearchCard(
              context,
              l10n.translate('seasonal_trends'),
              seasonalStatus,
              Icons.calendar_today_outlined,
              const Color(0xFFFFF3E0),
              const Color(0xFFE65100),
              l10n.translate('seasonal_desc'),
              l10n.translate('seasonal_help_text'),
            ),
            _buildResearchCard(
                context,
                l10n.translate('market_stability'),
                stabilityStatus,
                Icons.analytics_outlined,
                const Color(0xFFF3E5F5),
                stabilityColor,
                l10n.translate('stability_help_desc'),
                l10n.translate('stability_help_desc'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResearchCard(
      BuildContext context,
      String title,
      String status,
      IconData icon,
      Color bgColor,
      Color iconColor,
      String description,
      String helpText,
      ) {
    return GestureDetector(
      onTap: () => _showHelpDialog(context, title, helpText, AppLocalizations.of(context)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: ThemeConstants.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w600, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: GoogleFonts.outfit(fontSize: 9, color: Colors.grey, height: 1.3),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }


  List<AuctionData> _aggregateData(List<AuctionData> data, int windowSize) {
    if (data.isEmpty) return [];
    
    final List<AuctionData> result = [];
    for (int i = 0; i < data.length; i += windowSize) {
      final end = (i + windowSize < data.length) ? i + windowSize : data.length;
      final chunk = data.sublist(i, end);
      
      final avgPrice = chunk.map((e) => e.avgPrice).reduce((a, b) => a + b) / chunk.length;
      final maxPrice = chunk.map((e) => e.maxPrice).reduce((a, b) => a > b ? a : b);
      
      result.add(AuctionData(
        date: chunk.last.date,
        auctioneer: "Avg Market",
        maxPrice: maxPrice,
        avgPrice: avgPrice,
        quantity: chunk.map((e) => e.quantity).reduce((a, b) => a + b),
        quantityArrived: chunk.map((e) => e.quantityArrived ?? 0.0).reduce((a, b) => a + b),
        lots: chunk.map((e) => e.lots ?? 0).reduce((a, b) => a + b),
      ));
    }
    return result;
  }

  Widget _buildPulseInfoItem(BuildContext context, String label, String value, Color color, IconData icon) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showHelpDialog(context, label, value, AppLocalizations.of(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  label.toUpperCase().replaceAll(':', ''),
                  style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.outfit(color: color, fontSize: 16, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketSignalCards(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    final List<Map<String, dynamic>> availableTips = [];
    
    // 1. Value Comparison
    final currentPrice = insights.stats['current'] ?? 0.0;
    final diffPrice = (insights.sameDayLastYearPrice != null) ? (currentPrice - insights.sameDayLastYearPrice!).abs() : 0.0;
    
    String comparisonMsg = l10n.translate('combined_comparison_desc')
        .replaceAll('{avg_5_season_pct}', insights.vsFiveSeasonAvg.abs().toStringAsFixed(1))
        .replaceAll('{level}', l10n.translate(insights.vsFiveSeasonAvg >= 0 ? 'level_higher' : 'level_lower'))
        .replaceAll('{diff_amount}', NumberFormat("#,##0").format(diffPrice))
        .replaceAll('{yoy_level}', l10n.translate((insights.sameDayLastYearPrice != null && currentPrice >= insights.sameDayLastYearPrice!) ? 'level_higher' : 'level_lower'));
    
    // Removing percentages from comparisons for layman readability
    comparisonMsg = comparisonMsg.replaceAll(RegExp(r'\d+\.?\d*%'), '').replaceAll('  ', ' ').trim();
    if (comparisonMsg.endsWith(',')) comparisonMsg = comparisonMsg.substring(0, comparisonMsg.length - 1);

    availableTips.add({
      'text': comparisonMsg,
      'icon': insights.vsFiveSeasonAvg >= 0 ? Icons.trending_up : Icons.trending_down,
      'color': insights.vsFiveSeasonAvg >= 0 ? Colors.green : Colors.orange,
    });

    // 2. Selective Fallback Advisories (DEDUPLICATED)
    if (insights.headlineType != HeadlineType.seasonal) {
      for (var key in insights.farmerAdvisories) {
        if (availableTips.length >= 4) break;
        if (!key.contains('seasonal')) {
          availableTips.add({
            'text': _formatAdvisoryText(key, insights, l10n),
            'icon': Icons.lightbulb_outline,
            'color': ThemeConstants.primaryGreen,
          });
        }
      }
    }

    final finalTips = _showAllInsights ? availableTips : availableTips.take(2).toList();

    return Column(
      children: [
        ...finalTips.map((tipMap) {
          final tip = tipMap['text'] as String;
          final icon = tipMap['icon'] as IconData;
          final accentColor = tipMap['color'] as Color;

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: accentColor),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, color: accentColor, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                tip,
                                style: GoogleFonts.outfit(
                                  color: ThemeConstants.textDark,
                                  fontSize: 14,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
        if (availableTips.length > 2)
          TextButton.icon(
            onPressed: () => setState(() => _showAllInsights = !_showAllInsights),
            icon: Icon(_showAllInsights ? Icons.expand_less : Icons.expand_more, size: 20, color: ThemeConstants.primaryGreen),
            label: Text(
              _showAllInsights ? l10n.translate('show_less') : l10n.moreInsights,
              style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeConstants.primaryGreen),
            ),
          ),
      ],
    );
  }









  Widget _buildKeyStatisticsSection(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.keyStatistics,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.sectionOrange),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildMultiRowStatCard(
              l10n.priceLevelTitle,
              l10n.lastThreeSeasons,
              Icons.bar_chart,
              Colors.green,
              [
                _buildPriceLevelChart(context, insights, l10n),
              ],
              helpTitle: l10n.priceLevelHelpTitle,
              helpDesc: l10n.priceLevelHelpDesc,
              l10n: l10n,
            ),
            const SizedBox(height: 16),
            _buildMultiRowStatCard(
              l10n.highestLowestTitle,
              l10n.translate('full_history_label').replaceAll('{count}', insights.totalDataYearCount.toString()),
              Icons.unfold_more,
              ThemeConstants.actionOrange,
              [
                _buildCardRow(
                  context, 
                  l10n.highestSeenLabel, 
                  "₹${insights.fullStats['max']?.toStringAsFixed(0)}", 
                  l10n, 
                  icon: Icons.trending_up,
                  iconColor: Colors.green,
                  suffix: insights.highestPriceYear > 0 ? "(${insights.highestPriceYear})" : null,
                  badge: l10n.rareLabel, 
                  badgeColor: ThemeConstants.actionOrange, 
                  helpTitle: l10n.highestSeenHelpTitle, 
                  helpDesc: l10n.highestSeenHelpDesc
                ),
                const Divider(height: 24, color: Color(0xFFF3F0EC)),
                _buildCardRow(
                  context, 
                  l10n.lowestSeenLabel, 
                  "₹${insights.fullStats['min']?.toStringAsFixed(0)}", 
                  l10n, 
                  icon: Icons.trending_down,
                  iconColor: Colors.red,
                  suffix: insights.lowestPriceYear > 0 ? "(${insights.lowestPriceYear})" : null,
                  badge: l10n.rareLabel, 
                  badgeColor: Colors.blue, 
                  helpTitle: l10n.lowestSeenHelpTitle, 
                  helpDesc: l10n.lowestSeenHelpDesc
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMultiRowStatCard(
              l10n.marketRiskStability,
              l10n.vsLastYear, 
              Icons.security_outlined,
              ThemeConstants.primaryGreen,
              [
                _buildCardRow(
                  context, 
                  l10n.marketSpeed, 
                  "${insights.thirtyDayChange >= 0 ? '+' : ''}₹${(insights.thirtyDayChange.abs() * (insights.stats['mean'] ?? 1000) / 100).toStringAsFixed(0)}", 
                  l10n, 
                  icon: Icons.speed_outlined,
                  iconColor: insights.thirtyDayChange > 0 ? Colors.green : (insights.thirtyDayChange < 0 ? Colors.red : Colors.grey),
                  badge: l10n.translate(insights.statusBadge),
                  badgeColor: insights.statusBadge == 'market_strong' ? Colors.green : (insights.statusBadge == 'market_weakened' ? Colors.red : ThemeConstants.actionOrange),
                  helpTitle: l10n.volatilityHelpTitle, 
                  helpDesc: l10n.volatilityHelpDesc
                ),
                const Divider(height: 24, color: Color(0xFFF3F0EC)),
                _buildCardRow(
                  context, 
                  l10n.dailyRange, 
                  "± ₹${insights.thirtyDayStdDev.toStringAsFixed(0)}", 
                  l10n, 
                  icon: Icons.swap_vert_outlined,
                  iconColor: Colors.blueGrey,
                  helpTitle: l10n.stabilityHelpTitle, 
                  helpDesc: l10n.stabilityHelpDesc
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiRowStatCard(String title, String subtitle, IconData icon, Color color, List<Widget> children, {bool noHorizontalPadding = false, String? helpTitle, String? helpDesc, AppLocalizations? l10n}) {
    final header = Padding(
      padding: EdgeInsets.symmetric(horizontal: noHorizontalPadding ? 20 : 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: ThemeConstants.textDark)),
                    ),
                    if (helpTitle != null) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.info_outline, size: 12, color: ThemeConstants.neutralGrey),
                    ],
                  ],
                ),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: noHorizontalPadding ? 0 : 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (helpTitle != null && l10n != null)
            Builder(
              builder: (context) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showHelpDialog(context, helpTitle, helpDesc!, l10n),
                child: header,
              ),
            )
          else
            header,
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildPriceLevelChart(BuildContext context, MarketInsights insights, AppLocalizations l10n) {
    if (insights.seasonalAverages.isEmpty) {
      return SizedBox(
        height: 120,
        child: Center(child: Text(l10n.translate('no_seasonal_data'))),
      );
    }

    final data = insights.seasonalAverages;
    
    // Calculate "Nice" Y-Axis Range
    final values = data.map((e) => e.value).toList();
    double rawMin = values.reduce(min);
    double rawMax = values.reduce(max);
    
    // Add tight margin
    rawMin = rawMin * 0.99;
    rawMax = rawMax * 1.02; // Reduced from 1.15 to prevent large white space
    
    double range = rawMax - rawMin;
    double interval;
    if (range <= 200) {
      interval = 50;
    } else if (range <= 500) {
      interval = 100;
    } else {
      interval = 200;
    }

    double minY = (rawMin / interval).floorToDouble() * interval;
    double maxY = (rawMax / interval).ceilToDouble() * interval;

    return Column(
      children: [
        SizedBox(
          height: 180, // Increased height for better visibility
          child: Padding(
            padding: const EdgeInsets.only(top: 30, right: 10, left: 0),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      getTitlesWidget: (val, meta) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          '₹${NumberFormat("#,###").format(val.toInt())}',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      reservedSize: 45,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= data.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            data[index].key,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      interval: 1,
                      reservedSize: 28,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => ThemeConstants.forestGreen.withValues(alpha: 0.9),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index < 0 || index >= data.length) return null;
                        final key = data[index].key;
                        return LineTooltipItem(
                          "$key\n",
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                          children: [
                            TextSpan(
                              text: "₹${NumberFormat("#,##0").format(spot.y.round())}",
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: ThemeConstants.primaryGreen,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 5,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: ThemeConstants.primaryGreen,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          ThemeConstants.primaryGreen.withValues(alpha: 0.15),
                          ThemeConstants.primaryGreen.withValues(alpha: 0.0),
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
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ThemeConstants.secondaryGreen.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.avgPrice,
              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardRow(BuildContext context, String label, String value, AppLocalizations l10n, {IconData? icon, String? suffix, Color? iconColor, String? badge, Color? badgeColor, String? helpTitle, String? helpDesc}) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Icon(icon, color: iconColor ?? Colors.grey, size: 20),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (helpTitle != null) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.info_outline, size: 12, color: ThemeConstants.neutralGrey),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: value,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: ThemeConstants.textDark,
                          ),
                        ),
                        if (suffix != null)
                          TextSpan(
                            text: " $suffix",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: badgeColor?.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (helpTitle != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showHelpDialog(context, helpTitle, helpDesc!, l10n),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: content,
        ),
      );
    }
    return content;
  }



  Widget _buildDisclaimer(AppLocalizations l10n, MarketInsights insights) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ThemeConstants.softGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: ThemeConstants.neutralGrey),
                  const SizedBox(width: 12),
                  Text(
                    l10n.confidenceNote,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: ThemeConstants.neutralGrey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.disclaimerText,
                style: const TextStyle(fontSize: 13, color: ThemeConstants.textDark, height: 1.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.analyticsDisclaimer,
                style: GoogleFonts.outfit(fontSize: 12, color: ThemeConstants.neutralGrey, fontStyle: FontStyle.italic),
              ),
              if (insights.firstDataDate != null && insights.lastDataDate != null) ...[
                const SizedBox(height: 12),
                Text(
                  "${l10n.translate('data_range')}: ${AppDates.ui.format(insights.firstDataDate!)} - ${AppDates.ui.format(insights.lastDataDate!)}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
