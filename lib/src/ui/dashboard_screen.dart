import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:cardamom_analytics/src/ui/feedback_screen.dart';
import 'package:cardamom_analytics/src/ui/profile_screen.dart';
import 'package:cardamom_analytics/src/providers/locale_provider.dart';
import 'package:cardamom_analytics/src/providers/navigation_provider.dart';
import 'package:cardamom_analytics/src/ui/widgets/live_pulse_indicator.dart';
import 'package:cardamom_analytics/src/ui/widgets/upcoming_auctions_widget.dart';
import 'package:cardamom_analytics/src/providers/auction_schedule_provider.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _syncIconController;

  @override
  void initState() {
    super.initState();
    _syncIconController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _syncIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          final bool isAuctionTime = ref.watch(isAuctionLiveNowProvider).value ?? false;

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(historicalFullPricesProvider),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _buildAppBar(context, l10n, ref),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isAuctionTime) const SizedBox(height: 50), // Space for floating pill
                            _buildSyncStatusBanner(context, ref, l10n),
                            const SizedBox(height: 10),
                            _buildLatestAuctionsSection(context, prices, l10n, ref),
                            const SizedBox(height: 32),
                            const UpcomingAuctionsWidget(),
                            const SizedBox(height: 32),
                            _buildPriceTrendChart(prices, insights, l10n, ref),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Floating Live Indicator - only shown during auction hours
                if (isAuctionTime)
                  Positioned(
                    top: kToolbarHeight + 10, // Position below AppBar
                    left: 20,
                    right: 20,
                    child: SafeArea(
                      child: _buildLivePulsePopup(context, ref),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showAboutDialog(context),
            child: Image.asset(
              'assets/logo.png',
              height: 28,
              width: 28,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: GestureDetector(
              onTap: () => _showAboutDialog(context),
              child: Text(
                l10n.appTitle,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: ThemeConstants.forestGreen,
                  fontSize: 17, // Further reduction for long titles
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          constraints: const BoxConstraints(maxWidth: 40),
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.language, color: ThemeConstants.forestGreen, size: 20),
          onPressed: () => _showLanguageSelector(context, ref),
        ),
        IconButton(
          constraints: const BoxConstraints(maxWidth: 40),
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.person_outline, color: ThemeConstants.forestGreen, size: 20),
          onPressed: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const ProfileScreen())),
        ),
        GestureDetector(
          onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (context) => const FeedbackScreen())),
          child: const Padding(
            padding: EdgeInsets.only(right: 12, left: 4),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: ThemeConstants.forestGreen,
              child: Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white),
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

  Widget _buildPriceTrendChart(List<AuctionData> prices, MarketInsights insights, AppLocalizations l10n, WidgetRef ref) {
    if (prices.length < 5) return const SizedBox.shrink();

    final selectedRange = ref.watch(chartRangeProvider);
    
    // Filter data based on selected range
    final now = DateTime.now();
    DateTime cutoff;
    switch (selectedRange) {
      case ChartRange.oneMonth:
        cutoff = DateTime(now.year, now.month - 1, now.day);
        break;
      case ChartRange.sixMonths:
        cutoff = DateTime(now.year, now.month - 6, now.day);
        break;
      case ChartRange.oneYear:
        cutoff = DateTime(now.year - 1, now.month, now.day);
        break;
      case ChartRange.fiveYears:
        cutoff = DateTime(now.year - 5, now.month, now.day);
        break;
    }

    final filteredData = prices.where((p) => p.date.isAfter(cutoff)).toList().reversed.toList();
    if (filteredData.isEmpty) return const SizedBox.shrink();

    // Aggregation for smoothness on 1Y/5Y
    List<AuctionData> displayPoints = filteredData;
    if (selectedRange == ChartRange.fiveYears || selectedRange == ChartRange.oneYear) {
      final interval = selectedRange == ChartRange.fiveYears ? 14 : 3; 
      final List<AuctionData> aggregated = [];
      for (int i = 0; i < filteredData.length; i += interval) {
        aggregated.add(filteredData[i]);
      }
      displayPoints = aggregated;
    }

    final List<FlSpot> actualSpots = [];
    for (int i = 0; i < displayPoints.length; i++) {
      actualSpots.add(FlSpot(i.toDouble(), displayPoints[i].avgPrice));
    }

    // Min/Max Y with buffer for cleaner look
    final minVal = displayPoints.map((p) => p.avgPrice).reduce(min);
    final maxVal = displayPoints.map((p) => p.avgPrice).reduce(max);
    final rangeVal = maxVal - minVal;
    final minY = (minVal - (rangeVal * 0.15)).floorToDouble();
    final maxY = (maxVal + (rangeVal * 0.15)).ceilToDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.translate('price_trend'),
              style: GoogleFonts.outfit(
                  fontSize: 18, fontWeight: FontWeight.bold, color: ThemeConstants.textDark),
            ),
            _buildChartRangeSelector(ref, l10n),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: Colors.grey.withValues(alpha: 0.05), strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: (displayPoints.length / 3).clamp(1.0, double.infinity),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= displayPoints.length) return const SizedBox.shrink();
                            // Only show labels for start, middle, end or fixed intervals
                            String fmt = selectedRange == ChartRange.oneMonth ? 'd MMM' : 'MMM yy';
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                DateFormat(fmt, l10n.locale.languageCode).format(displayPoints[index].date),
                                style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold),
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
                        getTooltipColor: (touchedSpot) => const Color(0xFF1B4332).withValues(alpha: 0.9),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final index = spot.x.toInt();
                            if (index < 0 || index >= displayPoints.length) return null;
                            final date = displayPoints[index].date;
                            return LineTooltipItem(
                              "${DateFormat('d MMM yyyy', l10n.locale.languageCode).format(date)}\n",
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
                    maxX: (displayPoints.length - 1).toDouble(),
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      // Actual Price Line (Teal) - Thicker for prominence
                      LineChartBarData(
                        spots: actualSpots,
                        isCurved: true,
                        color: const Color(0xFF00695C),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF00695C).withValues(alpha: 0.25),
                              const Color(0xFF00695C).withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  l10n.averageDisclaimer,
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartRangeSelector(WidgetRef ref, AppLocalizations l10n) {
    final selectedRange = ref.watch(chartRangeProvider);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRangeButton(ref, ChartRange.oneMonth, l10n.range1m, selectedRange == ChartRange.oneMonth),
          _buildRangeButton(ref, ChartRange.sixMonths, l10n.range6m, selectedRange == ChartRange.sixMonths),
          _buildRangeButton(ref, ChartRange.oneYear, l10n.range1y, selectedRange == ChartRange.oneYear),
          _buildRangeButton(ref, ChartRange.fiveYears, l10n.rangeAll, selectedRange == ChartRange.fiveYears),
        ],
      ),
    );
  }

  Widget _buildRangeButton(WidgetRef ref, ChartRange range, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => ref.read(chartRangeProvider.notifier).state = range,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D6A4F) : Colors.transparent, // Darker forest green
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
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
      trailing: isSelected ? const Icon(Icons.stars, color: ThemeConstants.actionOrange, size: 16) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ThemeConstants.creamApp,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: ThemeConstants.forestGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_off_outlined, size: 64, color: ThemeConstants.forestGreen),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noHistoricalData,
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: ThemeConstants.forestGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.clickSyncHint,
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Action: Sync Live Data
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Trigger a real sync
                    await ref.read(syncServiceProvider).syncNewData(maxPages: 3);
                    ref.read(syncTriggerProvider.notifier).state++;
                  },
                  icon: const Icon(Icons.sync),
                  label: Text(l10n.syncNow, style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeConstants.forestGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action: Re-seed Historical
              TextButton.icon(
                onPressed: () {
                  ref.read(dataSeederServiceProvider).seedData(force: true).then((_) {
                    ref.read(syncTriggerProvider.notifier).state++;
                  });
                },
                icon: const Icon(Icons.history_edu),
                label: Text(l10n.forceReseedButton),
                style: TextButton.styleFrom(
                  foregroundColor: ThemeConstants.forestGreen.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestAuctionsSection(BuildContext context, List<AuctionData> prices, AppLocalizations l10n, WidgetRef ref) {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.latestAuctions,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1B4332),
                  ),
                ),
                ref.watch(lastSyncTimeProvider).when(
                      data: (time) {
                        if (time == null) return const SizedBox.shrink();
                        final String timeStr = DateFormat.jm(l10n.locale.languageCode).format(time);
                        return Text(
                          l10n.lastUpdated(timeStr),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => ref.read(navigationProvider.notifier).state = 3, // History index
                  child: Text(
                    l10n.translate('see_all'),
                    style: const TextStyle(color: ThemeConstants.primaryGreen, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.orange, size: 20),
                  onPressed: () {
                    ref.read(syncLoadingProvider.notifier).state = true;
                    ref.refresh(historicalFullPricesProvider);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            children: [
              Text(
                DateFormat('EEEE, MMM d, yyyy', l10n.locale.languageCode).format(latestDate),
                style: GoogleFonts.outfit(
                  color: const Color(0xFF1B4332),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ...latestAuctions.asMap().entries.take(2).map((entry) {
                final index = entry.key;
                final auction = entry.value;
                // If there are 2 auctions, latest (index 0) is Session 2, previous is Session 1
                String sessionLabel = '';
                if (latestAuctions.length >= 2) {
                  sessionLabel = index == 0 ? l10n.translate('session_2') : l10n.translate('session_1');
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCompactAuctionCard(
                    context, 
                    auction, 
                    l10n, 
                    isLatest: index == 0,
                    sessionLabel: sessionLabel,
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildCompactAuctionCard(BuildContext context, AuctionData auction, AppLocalizations l10n, {bool isLatest = false, String sessionLabel = ''}) {
    return InkWell(
      onTap: () => _showAuctionDetails(context, auction, l10n),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9).withValues(alpha: 0.7), // Light green tint
              borderRadius: BorderRadius.circular(24),
              border: isLatest ? Border.all(color: ThemeConstants.primaryGreen.withValues(alpha: 0.3), width: 1.5) : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.gavel_outlined, size: 18, color: Color(0xFF1B4332)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sessionLabel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            sessionLabel,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      Text(
                        auction.auctioneer,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B4332),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.translate('tap_for_details'),
                        style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹ ${NumberFormat("#,##0").format(auction.avgPrice)}",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B4332),
                      ),
                    ),
                    Text(
                      "Max: ₹${NumberFormat("#,##0").format(auction.maxPrice)}",
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isLatest)
            Positioned(
              top: -8,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Text(
                  l10n.translate('latest_tag'),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
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
            child: Text(l10n.translate('close'), style: const TextStyle(color: ThemeConstants.forestGreen, fontWeight: FontWeight.bold)),
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

  Widget _buildSyncStatusBanner(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final isSyncing = ref.watch(syncLoadingProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(sizeFactor: animation, child: child),
      ),
      child: isSyncing
          ? Container(
              key: const ValueKey('syncing_banner'),
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ThemeConstants.forestGreen.withValues(alpha: 0.08),
                    ThemeConstants.forestGreen.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: ThemeConstants.forestGreen.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeConstants.forestGreen.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  RotationTransition(
                    turns: _syncIconController,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: ThemeConstants.forestGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sync,
                        size: 16,
                        color: ThemeConstants.forestGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.translate('syncing_server'),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: ThemeConstants.forestGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.initialSyncHint,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: ThemeConstants.forestGreen.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty_banner')),
    );
  }

  Widget _buildLivePulsePopup(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: LivePulseIndicator(
        text: l10n.translate('live_auction_now'),
        onTap: () => ref.read(navigationProvider.notifier).state = 2,
      ),
    );
  }
}
